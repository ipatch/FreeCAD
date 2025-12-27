# SPDX-License-Identifier: LGPL-2.1-or-later

# **************************************************************************
#   Copyright (c) 2025 FreeCAD contributors                                *
#                                                                          *
#   This file is part of FreeCAD.                                          *
#                                                                          *
#   FreeCAD is free software: you can redistribute it and/or modify it     *
#   under the terms of the GNU Lesser General Public License as            *
#   published by the Free Software Foundation, either version 2.1 of the   *
#   License, or (at your option) any later version.                        *
#                                                                          *
#   FreeCAD is distributed in the hope that it will be useful, but         *
#   WITHOUT ANY WARRANTY; without even the implied warranty of             *
#   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU       *
#   Lesser General Public License for more details.                        *
#                                                                          *
#   You should have received a copy of the GNU Lesser General Public       *
#   License along with FreeCAD. If not, see                                *
#   <https://www.gnu.org/licenses/>.                                       *
#                                                                          *
# **************************************************************************

"""
Regression tests for STEP export naming issues.

Issue #24962: STEP export should preserve Body names, not use tip feature names
              or parent Part names for child objects.
"""

import os
import tempfile
import unittest

import FreeCAD as App
import Part


class TestStepExportBodyName(unittest.TestCase):
    """Test that STEP export preserves object names correctly."""

    def setUp(self):
        """Create a new document for each test."""
        self.doc = App.newDocument("TestStepExportBodyName")
        self.temp_dir = tempfile.gettempdir()

    def tearDown(self):
        """Clean up document."""
        App.closeDocument(self.doc.Name)

    def _create_body_with_pad(self, body_label, pad_label="Pad"):
        """
        Helper to create a PartDesign::Body with a simple Pad feature.
        
        Args:
            body_label: Label for the Body object
            pad_label: Label for the Pad feature (tip)
            
        Returns:
            tuple: (body, pad) objects
        """
        import Sketcher
        
        # Create Body
        body = self.doc.addObject("PartDesign::Body", "Body")
        body.Label = body_label
        
        # Create Sketch attached to XY plane
        sketch = self.doc.addObject("Sketcher::SketchObject", "Sketch")
        body.addObject(sketch)
        
        # Attach to XY_Plane of the body's origin
        xy_plane = body.Origin.OriginFeatures[3]  # XY_Plane
        sketch.AttachmentSupport = [(xy_plane, "")]
        sketch.MapMode = "FlatFace"
        
        # Draw a simple 10x10 rectangle
        sketch.addGeometry(Part.LineSegment(App.Vector(0, 0, 0), App.Vector(10, 0, 0)), False)
        sketch.addGeometry(Part.LineSegment(App.Vector(10, 0, 0), App.Vector(10, 10, 0)), False)
        sketch.addGeometry(Part.LineSegment(App.Vector(10, 10, 0), App.Vector(0, 10, 0)), False)
        sketch.addGeometry(Part.LineSegment(App.Vector(0, 10, 0), App.Vector(0, 0, 0)), False)
        
        # Close the rectangle with coincident constraints
        sketch.addConstraint(Sketcher.Constraint("Coincident", 0, 2, 1, 1))
        sketch.addConstraint(Sketcher.Constraint("Coincident", 1, 2, 2, 1))
        sketch.addConstraint(Sketcher.Constraint("Coincident", 2, 2, 3, 1))
        sketch.addConstraint(Sketcher.Constraint("Coincident", 3, 2, 0, 1))
        
        # Create Pad
        pad = self.doc.addObject("PartDesign::Pad", "Pad")
        pad.Label = pad_label
        body.addObject(pad)
        pad.Profile = sketch
        pad.Length = 5.0
        
        self.doc.recompute()
        
        return body, pad

    def test_part_children_preserve_their_own_names(self):
        """
        Regression test for issue #24962.
        
        When exporting an App::Part containing multiple children to STEP,
        each child should preserve its own name, NOT inherit the parent
        Part's name.
        
        This recreates the exact structure from the user's test file:
        
        Setup:
            - App::Part with Label="PartA"
              - Part::Sphere with Label="SphereA"
              - PartDesign::Body with Label="BodyA"
                - Sketch
                - Pad with Label="PadA"
                
        Expected on reimport:
            - Objects named "SphereA" and "BodyA" (or similar preserving child names)
            - NOT two objects both named "PartA"
            - NOT objects named "PadA" (the tip feature)
        """
        import Import
        
        # Create the Part container
        part = self.doc.addObject("App::Part", "Part")
        part.Label = "PartA"
        
        # Add a Sphere directly to Part
        sphere = self.doc.addObject("Part::Sphere", "Sphere")
        sphere.Label = "SphereA"
        sphere.Radius = 5.0
        part.addObject(sphere)
        
        # Create Body with Pad inside the Part
        body, pad = self._create_body_with_pad("BodyA", "PadA")
        part.addObject(body)
        
        self.doc.recompute()
        
        step_file = os.path.join(self.temp_dir, "test_part_children_names_24962.step")
        
        try:
            # Export the Part (container with children) to STEP
            Import.export([part], step_file)
            self.assertTrue(os.path.exists(step_file), "STEP file was not created")
            
            # Import into fresh document
            import_doc = App.newDocument("TestImport")
            try:
                Import.insert(step_file, import_doc.Name)
                import_doc.recompute()
                
                # Find imported Part::Feature objects
                part_features = [
                    obj for obj in import_doc.Objects
                    if obj.isDerivedFrom("Part::Feature")
                ]
                
                self.assertGreater(len(part_features), 0, "No Part::Feature objects imported")
                
                imported_labels = [obj.Label for obj in part_features]
                
                # THE KEY BUG: Children should NOT all be named after the parent "PartA"
                part_a_count = sum(1 for label in imported_labels if label.startswith("PartA"))
                
                # We expect 2 shapes (sphere + body), they should NOT both be named PartA
                self.assertLess(
                    part_a_count, 2,
                    f"Bug #24962: Multiple objects named 'PartA*' - children lost their names. "
                    f"Got: {imported_labels}"
                )
                
                # Child names should be preserved (SphereA and BodyA)
                has_sphere_name = any("Sphere" in label for label in imported_labels)
                has_body_name = any("Body" in label for label in imported_labels)
                
                self.assertTrue(
                    has_sphere_name or has_body_name,
                    f"Expected child names (SphereA/BodyA) to be preserved, got: {imported_labels}"
                )
                
                # Tip feature name (PadA) should NOT be used
                pad_count = sum(1 for label in imported_labels if "Pad" in label)
                self.assertEqual(
                    pad_count, 0,
                    f"Tip feature name 'PadA' should not appear: {imported_labels}"
                )
                
            finally:
                App.closeDocument(import_doc.Name)
                
        finally:
            if os.path.exists(step_file):
                os.remove(step_file)

    def test_standalone_body_preserves_name(self):
        """
        Test that a standalone Body (not in a Part) preserves its name.
        
        Setup:
            - PartDesign::Body with Label="MyTestBody"
              - Pad with Label="Pad"
                
        Expected:
            - Imported object named "MyTestBody", NOT "Pad"
        """
        import Import
        
        body, pad = self._create_body_with_pad("MyTestBody", "Pad")
        
        step_file = os.path.join(self.temp_dir, "test_standalone_body_24962.step")
        
        try:
            Import.export([body], step_file)
            self.assertTrue(os.path.exists(step_file), "STEP file was not created")
            
            import_doc = App.newDocument("TestImport")
            try:
                Import.insert(step_file, import_doc.Name)
                import_doc.recompute()
                
                part_features = [
                    obj for obj in import_doc.Objects
                    if obj.isDerivedFrom("Part::Feature")
                ]
                
                self.assertEqual(len(part_features), 1, "Expected exactly 1 imported object")
                
                imported_label = part_features[0].Label
                
                self.assertEqual(
                    imported_label, "MyTestBody",
                    f"Expected 'MyTestBody', got '{imported_label}'"
                )
                
            finally:
                App.closeDocument(import_doc.Name)
                
        finally:
            if os.path.exists(step_file):
                os.remove(step_file)

    def test_multiple_bodies_in_part_preserve_names(self):
        """
        Test multiple bodies inside a Part each preserve their names.
        
        Setup:
            - App::Part with Label="Assembly"
              - PartDesign::Body with Label="LeftBracket"
              - PartDesign::Body with Label="RightBracket"
                
        Expected:
            - Imported objects include "LeftBracket" and "RightBracket"
            - NOT two objects both named "Assembly"
        """
        import Import
        import Sketcher
        
        # Create Part container
        part = self.doc.addObject("App::Part", "Part")
        part.Label = "Assembly"
        
        # First body
        body1, _ = self._create_body_with_pad("LeftBracket", "Pad")
        part.addObject(body1)
        
        # Second body - create manually to avoid name conflicts
        body2 = self.doc.addObject("PartDesign::Body", "Body002")
        body2.Label = "RightBracket"
        part.addObject(body2)
        
        sketch2 = self.doc.addObject("Sketcher::SketchObject", "Sketch002")
        body2.addObject(sketch2)
        xy_plane2 = body2.Origin.OriginFeatures[3]
        sketch2.AttachmentSupport = [(xy_plane2, "")]
        sketch2.MapMode = "FlatFace"
        
        # Offset rectangle for second body
        sketch2.addGeometry(Part.LineSegment(App.Vector(20, 0, 0), App.Vector(30, 0, 0)), False)
        sketch2.addGeometry(Part.LineSegment(App.Vector(30, 0, 0), App.Vector(30, 10, 0)), False)
        sketch2.addGeometry(Part.LineSegment(App.Vector(30, 10, 0), App.Vector(20, 10, 0)), False)
        sketch2.addGeometry(Part.LineSegment(App.Vector(20, 10, 0), App.Vector(20, 0, 0)), False)
        sketch2.addConstraint(Sketcher.Constraint("Coincident", 0, 2, 1, 1))
        sketch2.addConstraint(Sketcher.Constraint("Coincident", 1, 2, 2, 1))
        sketch2.addConstraint(Sketcher.Constraint("Coincident", 2, 2, 3, 1))
        sketch2.addConstraint(Sketcher.Constraint("Coincident", 3, 2, 0, 1))
        
        pad2 = self.doc.addObject("PartDesign::Pad", "Pad002")
        pad2.Label = "Pad"
        body2.addObject(pad2)
        pad2.Profile = sketch2
        pad2.Length = 8.0
        
        self.doc.recompute()
        
        step_file = os.path.join(self.temp_dir, "test_multi_body_part_24962.step")
        
        try:
            Import.export([part], step_file)
            self.assertTrue(os.path.exists(step_file), "STEP file was not created")
            
            import_doc = App.newDocument("TestImport")
            try:
                Import.insert(step_file, import_doc.Name)
                import_doc.recompute()
                
                part_features = [
                    obj for obj in import_doc.Objects
                    if obj.isDerivedFrom("Part::Feature")
                ]
                
                imported_labels = [obj.Label for obj in part_features]
                
                # Should NOT have multiple objects named "Assembly"
                assembly_count = sum(1 for label in imported_labels if label.startswith("Assembly"))
                self.assertLess(
                    assembly_count, 2,
                    f"Bug: Multiple objects got parent name 'Assembly': {imported_labels}"
                )
                
                # Should have the body names
                has_left = any("LeftBracket" in label for label in imported_labels)
                has_right = any("RightBracket" in label for label in imported_labels)
                
                self.assertTrue(
                    has_left and has_right,
                    f"Expected 'LeftBracket' and 'RightBracket', got: {imported_labels}"
                )
                
            finally:
                App.closeDocument(import_doc.Name)
                
        finally:
            if os.path.exists(step_file):
                os.remove(step_file)


# For running with: ./path/to/FreeCAD --run-test TestStepExportBodyName
if __name__ == "__main__":
    unittest.main()
