#**************************************************************************
#   Copyright (c) 2017 Kurt Kremitzki <kkremitzki@gmail.com>              *
#                                                                         *
#   This file is part of the FreeCAD CAx development system.              *
#                                                                         *
#   This program is free software; you can redistribute it and/or modify  *
#   it under the terms of the GNU Lesser General Public License (LGPL)    *
#   as published by the Free Software Foundation; either version 2 of     *
#   the License, or (at your option) any later version.                   *
#   for detail see the LICENCE text file.                                 *
#                                                                         *
#   FreeCAD is distributed in the hope that it will be useful,            *
#   but WITHOUT ANY WARRANTY; without even the implied warranty of        *
#   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the         *
#   GNU Library General Public License for more details.                  *
#                                                                         *
#   You should have received a copy of the GNU Library General Public     *
#   License along with FreeCAD; if not, write to the Free Software        *
#   Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  *
#   USA                                                                   *
#**************************************************************************
from math import pi
import unittest

import FreeCAD
import TestSketcherApp

App = FreeCAD

class TestHole(unittest.TestCase):
    def setUp(self):
        self.Doc = FreeCAD.newDocument("PartDesignTestHole")
        self.Body = self.Doc.addObject('PartDesign::Body','Body')
        self.Box = self.Doc.addObject('PartDesign::AdditiveBox','Box')
        self.Box.Length=10
        self.Box.Width=10
        self.Box.Height=10
        self.Body.addObject(self.Box)
        self.Doc.recompute()
        self.HoleSketch = self.Doc.addObject('Sketcher::SketchObject', 'SketchHole')
        self.HoleSketch.AttachmentSupport = (self.Doc.XY_Plane, [''])
        self.HoleSketch.MapMode = 'FlatFace'
        self.HoleSketch.MapReversed = True
        self.Body.addObject(self.HoleSketch)
        TestSketcherApp.CreateCircleSketch(self.HoleSketch, (-5, 5),  1)
        self.Doc.recompute()
        self.Hole = self.Doc.addObject("PartDesign::Hole", "Hole")
        self.Hole.Profile = self.HoleSketch
        self.Body.addObject(self.Hole)
        self.Doc.recompute()

    def testPlainHole(self):
        self.Hole.Diameter = 6
        self.Hole.Depth = 10
        # self.Hole.DrillPointAngle = 118.000000
        # self.Hole.TaperedAngle = 90
        self.Hole.ThreadType = 0
        self.Hole.HoleCutType = 0 # 1 = Counterbore, 2 = Countersink
        # self.Hole.HoleCutDiameter = 5
        # self.Hole.HoleCutCountersinkAngle = 90
        # self.Hole.HoleCutDepth = 2 # Counterbore
        self.Hole.DepthType = 0 # 1 = Through all
        self.Hole.DrillPoint = 0 # 1 = Angled
        self.Hole.Tapered = 0 # On/off
        self.Doc.recompute()
        self.assertAlmostEqual(self.Hole.Shape.Volume, 10**3 - pi * 3**2 * 10)

    def testTaperedHole(self):
        self.Hole.Diameter = 6
        self.Hole.Depth = 5
        self.Hole.TaperedAngle = 60
        self.Hole.ThreadType = 0
        self.Hole.HoleCutType = 0
        self.Hole.DepthType = 0
        self.Hole.DrillPoint = 0
        self.Hole.Tapered = 1
        self.Doc.recompute()
        self.assertEqual(len(self.Hole.Shape.Faces), 8)

    def testAngledDrillHole(self):
        self.Hole.Diameter = 6
        self.Hole.Depth = 10
        self.Hole.DrillPointAngle = 118
        self.Hole.ThreadType = 0
        self.Hole.HoleCutType = 0
        self.Hole.DepthType = 0
        self.Hole.DrillPoint = 1
        self.Hole.Tapered = 0
        self.Hole.DrillForDepth = 1
        self.Doc.recompute()
        self.assertEqual(len(self.Hole.Shape.Faces), 8)

    def testCounterboreHole(self):
        self.Hole.Diameter = 6
        self.Hole.Depth = 10
        self.Hole.ThreadType = 0
        self.Hole.HoleCutType = 1
        self.Hole.HoleCutDiameter = 8
        self.Hole.HoleCutDepth = 5
        self.Hole.DepthType = 0
        self.Hole.DrillPoint = 0
        self.Hole.Tapered = 0
        self.Doc.recompute()
        self.assertAlmostEqual(self.Hole.Shape.Volume, 10**3 - pi * 3**2 * 5 - pi * 4**2 * 5)

    def testCountersinkHole(self):
        self.Hole.Diameter = 6
        self.Hole.Depth = 10
        self.Hole.ThreadType = 0
        self.Hole.HoleCutType = 2
        self.Hole.HoleCutDiameter = 9
        self.Hole.HoleCutCountersinkAngle = 90
        self.Hole.DepthType = 0
        self.Hole.DrillPoint = 0
        self.Hole.Tapered = 0
        self.Doc.recompute()
        self.assertAlmostEqual(self.Hole.Shape.Volume, 10**3 - pi * 3**2 * 10 - 24.7400421)

    def testNoRefineHole(self):
        # Add a second box to get a shape with more faces
        self.Box2 = self.Doc.addObject('PartDesign::AdditiveBox','Box')
        self.Box2.Length=10
        self.Box2.Width=10
        self.Box2.Height=10
        self.Box2.AttacherEngine = u"Engine 3D"
        self.Box2.AttachmentOffset = App.Placement(
            App.Vector(1.0000000000, 0.0000000000, 0.0000000000),
            App.Rotation(0.0000000000, 0.0000000000, 0.0000000000),
        )
        self.Box2.MapReversed = False
        self.Box2.AttachmentSupport = self.Doc.getObject('XY_Plane')
        self.Box2.MapPathParameter = 0.000000
        self.Box2.MapMode = 'FlatFace'

        # Set the Refine option to False, otherwise adding the second box would be useless
        self.Box2.Refine = False
        self.Body.addObject(self.Box2)
        self.Doc.recompute()

        # Move the Hole on top of the Body
        self.Body.removeObject(self.Hole)
        self.Body.insertObject(self.Hole,self.Box2, True)
        self.Body.Tip = self.Hole
        self.Hole.Diameter = 6
        self.Hole.Depth = 10
        self.Hole.ThreadType = 0
        self.Hole.HoleCutType = 0
        self.Hole.DepthType = 0
        self.Hole.DrillPoint = 0
        self.Hole.Tapered = 0
        self.Hole.Visibility = True

        # Test the number of faces with the Refine option set to False
        self.Hole.Refine = False
        self.Doc.recompute()
        self.assertEqual(len(self.Hole.Shape.Faces), 15)

    def testRefineHole(self):
        # Add a second box to get a shape with more faces
        self.Box2 = self.Doc.addObject('PartDesign::AdditiveBox','Box')
        self.Box2.Length=10
        self.Box2.Width=10
        self.Box2.Height=10
        self.Box2.AttacherEngine = u"Engine 3D"
        self.Box2.AttachmentOffset = App.Placement(
            App.Vector(1.0000000000, 0.0000000000, 0.0000000000),
            App.Rotation(0.0000000000, 0.0000000000, 0.0000000000),
        )
        self.Box2.MapReversed = False
        self.Box2.AttachmentSupport = self.Doc.getObject('XY_Plane')
        self.Box2.MapPathParameter = 0.000000
        self.Box2.MapMode = 'FlatFace'

        # Set the Refine option to False, otherwise adding the second box would be useless
        self.Box2.Refine = False
        self.Body.addObject(self.Box2)
        self.Doc.recompute()

        # Move the Hole on top of the Body
        self.Body.removeObject(self.Hole)
        self.Body.insertObject(self.Hole,self.Box2, True)
        self.Body.Tip = self.Hole
        self.Hole.Diameter = 6
        self.Hole.Depth = 10
        self.Hole.ThreadType = 0
        self.Hole.HoleCutType = 0
        self.Hole.DepthType = 0
        self.Hole.DrillPoint = 0
        self.Hole.Tapered = 0
        self.Hole.Visibility = True

        # Test the number of faces with the Refine option set to True
        self.Hole.Refine = True
        self.Doc.recompute()
        self.assertEqual(len(self.Hole.Shape.Faces), 7)

    def tearDown(self):
        #closing doc
        FreeCAD.closeDocument("PartDesignTestHole")
        #print ("omit closing document for debugging")

