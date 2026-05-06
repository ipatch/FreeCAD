# SPDX-License-Identifier: LGPL-2.1-or-later
# (license header — same as before)

import unittest
import FreeCAD, Sketcher
App = FreeCAD


class TestSketcherEditMode(unittest.TestCase):
    """Regression tests for Sketcher edit-mode state.

    Tests that ViewProviderSketch::setEdit() invokes
    Workbench::enterEditMode() (via setupActiveAndInEdit), so that
    SketcherGui.isInEditMode() reflects the active edit state.

    Originally added for issue #29738, where the workbench failed to
    enter edit mode on the second sketch in a session, leaving the
    edit-mode toolbars hidden.

    LIMITATION: programmatic gdoc.setEdit() from unittest takes a
    different code path than user-driven sketch entry (tree double-
    click) and may invoke setupActiveAndInEdit() even when the GUI
    path does not. This test catches the case where enterEditMode()
    is never called for any reason; the path-specific manifestation
    of #29738 requires manual verification with the repro file from
    the issue.
    """

    def setUp(self):
        if not App.GuiUp:
            self.skipTest("Requires GUI")
        self.doc = App.newDocument("TestSketcherEditMode")

    def tearDown(self):
        import FreeCADGui
        gdoc = FreeCADGui.getDocument(self.doc.Name)
        if gdoc and gdoc.getInEdit():
            gdoc.resetEdit()
        App.closeDocument(self.doc.Name)

    def _addSketch(self, name):
        sk = self.doc.addObject("Sketcher::SketchObject", name)
        self.doc.recompute()
        return sk

    def testEnterEditModeFirstSketch(self):
        """Sanity check: editing a single sketch enters edit mode."""
        import FreeCADGui
        import SketcherGui

        sk = self._addSketch("Sketch1")
        FreeCADGui.getDocument(self.doc.Name).setEdit(sk.Name)
        self.assertTrue(
            SketcherGui.isInEditMode(),
            "Workbench should be in edit mode after setEdit",
        )

        FreeCADGui.getDocument(self.doc.Name).resetEdit()
        self.assertFalse(
            SketcherGui.isInEditMode(),
            "Workbench should leave edit mode after resetEdit",
        )

    def testEnterEditModeSecondSketchSameDoc(self):
        """Regression test for issue #29738.

        Editing a second sketch in the same document must enter edit
        mode, not silently skip the toolbar setup.
        """
        import FreeCADGui
        import SketcherGui

        sk1 = self._addSketch("Sketch1")
        sk2 = self._addSketch("Sketch2")
        gdoc = FreeCADGui.getDocument(self.doc.Name)

        gdoc.setEdit(sk1.Name)
        self.assertTrue(
            SketcherGui.isInEditMode(),
            "First sketch: workbench should be in edit mode",
        )
        gdoc.resetEdit()
        self.assertFalse(
            SketcherGui.isInEditMode(),
            "First sketch: workbench should leave edit mode",
        )

        gdoc.setEdit(sk2.Name)
        self.assertTrue(
            SketcherGui.isInEditMode(),
            "Second sketch: workbench should be in edit mode "
            "(regression #29738)",
        )
        gdoc.resetEdit()

    def testEnterEditModeAcrossDocuments(self):
        """Regression test for issue #29738 (multi-document case).

        Editing sketches in two different documents must enter edit
        mode each time. This is the scenario from the original issue
        report.
        """
        import FreeCADGui
        import SketcherGui

        skA = self._addSketch("SketchA")
        gdocA = FreeCADGui.getDocument(self.doc.Name)
        gdocA.setEdit(skA.Name)
        self.assertTrue(
            SketcherGui.isInEditMode(),
            "Doc A: should be in edit mode",
        )
        gdocA.resetEdit()

        docB = App.newDocument("TestSketcherEditMode_B")
        try:
            skB = docB.addObject("Sketcher::SketchObject", "SketchB")
            docB.recompute()
            gdocB = FreeCADGui.getDocument(docB.Name)
            gdocB.setEdit(skB.Name)
            self.assertTrue(
                SketcherGui.isInEditMode(),
                "Doc B: should be in edit mode after switching docs "
                "(regression #29738)",
            )
            gdocB.resetEdit()
        finally:
            App.closeDocument(docB.Name)
