/-
Copyright (c) 2024 Sina Hazratpour. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Sina Hazratpour
-/
import Mathlib.CategoryTheory.Category.Cat
import Mathlib.CategoryTheory.Arrow
import Mathlib.CategoryTheory.Opposites
import Mathlib.CategoryTheory.Elements
import Mathlib.CategoryTheory.Equivalence
import Mathlib.CategoryTheory.Grothendieck
import LeanFibredCategories.ForMathlib.Displayed.Fiber
import LeanFibredCategories.ForMathlib.Displayed.Basic
import LeanFibredCategories.ForMathlib.Displayed.Cartesian

set_option pp.explicit false
--set_option pp.notation true
set_option trace.simps.verbose true
--set_option trace.Meta.synthInstance.instances true
--set_option trace.Meta.synthInstance true
set_option pp.coercions true

namespace CategoryTheory

open Category Opposite BasedLift Fiber FiberCat Display


namespace Display

variable {C : Type*} [Category C] (F : C → Type*) [Display F]

#check CartLift


end Display
