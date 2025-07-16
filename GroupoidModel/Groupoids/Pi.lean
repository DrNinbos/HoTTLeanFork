import GroupoidModel.Groupoids.Sigma
import GroupoidModel.Syntax.NaturalModel
import GroupoidModel.ForMathlib.CategoryTheory.Whiskering
import GroupoidModel.ForMathlib.CategoryTheory.NatTrans

universe v u v₁ u₁ v₂ u₂ v₃ u₃

noncomputable section
-- NOTE temporary section for stuff to be moved elsewhere
section ForOther

lemma hcongr_fun {α α' : Type u} (hα : α ≍ α') (β : α → Type v) (β' : α' → Type v) (hβ : β ≍ β')
    (f : (x : α) → β x) (f' : (x : α') → β' x) (hf : f ≍ f')
    {x : α} {x' : α'} (hx : x ≍ x') : f x ≍ f' x' := by
  subst hα hβ hf hx
  rfl

namespace CategoryTheory

open Functor

lemma Grpd.Functor.hcongr_obj {C C' D D' : Grpd.{v,u}} (hC : C = C') (hD : D = D')
    {F : C ⥤ D} {F' : C' ⥤ D'} (hF : F ≍ F') {x} {x'} (hx : x ≍ x') :
    HEq (F.obj x) (F'.obj x') := by
  subst hC hD hF hx
  rfl

lemma Grpd.whiskerLeft_hcongr_right {C D : Type*} [Category C] [Category D]
    {E E' : Grpd.{v,u}} (hE : E ≍ E') (F : C ⥤ D) {G H : D ⥤ E} {G' H' : D ⥤ E'}
    (hG : G ≍ G') (hH : H ≍ H') {α : G ⟶ H} {α' : G' ⟶ H'} (hα : α ≍ α') :
    whiskerLeft F α ≍ whiskerLeft F α' := by
  subst hE hG hH hα
  rfl

lemma Grpd.comp_hcongr {C C' D D' E E' : Grpd.{v,u}} (hC : C ≍ C') (hD : D ≍ D')
    (hE : E ≍ E') {F : C ⥤ D} {F' : C' ⥤ D'} {G : D ⥤ E} {G' : D' ⥤ E'}
    (hF : F ≍ F') (hG : G ≍ G')
    : F ⋙ G ≍ F' ⋙ G' := by
  subst hC hD hE hF hG
  rfl

lemma Grpd.NatTrans.hext {X X' Y Y' : Grpd.{v,u}} (hX : X = X') (hY : Y = Y')
    {F G : X ⥤ Y} {F' G' : X' ⥤ Y'} (hF : F ≍ F') (hG : G ≍ G')
    (α : F ⟶ G) (α' : F' ⟶ G') (happ : ∀ x : X, α.app x ≍ α'.app ((eqToHom hX).obj x)) :
    α ≍ α' := by
  subst hX hY hF hG
  aesop_cat

section
variable {A B : Type*} [Category A] [Category B] (F : B ⥤ A)

-- NOTE to follow mathlib convention can use camelCase for definitions, and capitalised first letter when that definition is a Prop or Type
def IsSection (s : A ⥤ B) := s ⋙ F = Functor.id A

abbrev Section := ObjectProperty.FullSubcategory (IsSection F)

instance Section.category : Category (Section F) :=
  ObjectProperty.FullSubcategory.category (IsSection F)

abbrev Section.ι : Section F ⥤ (A ⥤ B) :=
  ObjectProperty.ι (IsSection F)

end

namespace ObjectProperty

-- JH: after the golfs, we don't acuse this lemma anymore,
-- but it is still probably useful?
lemma ι_mono {T C : Type u} [Category.{v} C] [Category.{v} T]
    {Z : C → Prop} (f g : T ⥤ FullSubcategory Z)
    (e : f ⋙ ι Z = g ⋙ ι Z) : f = g := by
  apply CategoryTheory.Functor.ext_of_iso _ _ _
  · exact Functor.fullyFaithfulCancelRight (ι Z) (eqToIso e)
  · intro X
    ext
    exact Functor.congr_obj e X
  · intro X
    simp only [Functor.fullyFaithfulCancelRight_hom_app, Functor.preimage, ι_obj, ι_map,
      eqToIso.hom, eqToHom_app, Functor.comp_obj, Classical.choose_eq]
    rfl


end ObjectProperty

instance {C : Type*} [Groupoid C] (P : ObjectProperty C) :
    Groupoid (P.FullSubcategory) :=
  InducedCategory.groupoid C (ObjectProperty.ι _).obj

instance Grpd.ι_mono (G : Grpd) (P : ObjectProperty G) : Mono (Grpd.homOf (ObjectProperty.ι P)) :=
  ⟨ fun _ _ e => ObjectProperty.ι_mono _ _ e ⟩

-- lemma Grpd.ObjectProperty.fullSubcategory_heq {A A' : Grpd.{v,u}} (hA : A ≍ A')
--     (P : ObjectProperty A) (P' : ObjectProperty A') (hP : ∀ x : A, P x ↔ P' (hA.elim x)) :
--     (⟨ ObjectProperty.FullSubcategory P, inferInstance ⟩ : Grpd) ≍
--     (⟨ ObjectProperty.FullSubcategory P', inferInstance ⟩ : Grpd) := by
--   subst hA
--   have : P = P' := by aesop
--   rw [this]

lemma Grpd.ObjectProperty.FullSubcategory.hext {A A' : Grpd.{v,u}} (hA : A ≍ A')
    (P : ObjectProperty A) (P' : ObjectProperty A') (hP : P ≍ P')
    (a : A) (a' : A') (ha : a ≍ a') (ha : P a) (ha' : P' a') :
    (⟨ a, ha ⟩ : P.FullSubcategory) ≍ (⟨ a', ha' ⟩ : P'.FullSubcategory) := by
  subst hA ha hP
  rfl

end CategoryTheory

end ForOther

-- NOTE content for this doc starts here
namespace GroupoidModel

open CategoryTheory NaturalModelBase Opposite Grothendieck.Groupoidal  Groupoid

attribute [local simp] eqToHom_map Grpd.id_eq_id Grpd.comp_eq_comp Functor.id_comp Functor.comp_id


-- @yiming can we remove this?
/-
   Uncomment this to see the the flow of organizing Conjugation into the Conjugating functor.
   def Conjugating0 {Γ : Grpd.{v,u}} (A B : Γ ⥤ Grpd.{u₁,u₁})
    {x y: Γ } (f: x ⟶ y) : (A.obj x⥤ B.obj x) ⥤ (A.obj y⥤ B.obj y) :=
     let wr : B.obj x ⥤ B.obj y := B.map f
     let wl : A.obj y ⥤ A.obj x := A.map (Groupoid.inv f)
     let f1_ty : (A.obj y ⥤ A.obj x) ⥤ ((A.obj x) ⥤ (B.obj x)) ⥤ (A.obj y) ⥤  (B.obj x) :=
       whiskeringLeft (A.obj y) (A.obj x) (B.obj x)
     let f1 : ((A.obj x) ⥤ (B.obj x)) ⥤ (A.obj y) ⥤  (B.obj x) :=
       (whiskeringLeft (A.obj y) (A.obj x) (B.obj x)).obj (A.map (Groupoid.inv f))
     let f2_ty :  ((B.obj x) ⥤ (B.obj y)) ⥤ (A.obj y ⥤ B.obj x) ⥤ (A.obj y) ⥤  (B.obj y) :=
       whiskeringRight (A.obj y) (B.obj x) (B.obj y)
     let f2 : (A.obj y ⥤ B.obj x) ⥤ (A.obj y) ⥤  (B.obj y) :=
       (whiskeringRight (A.obj y) (B.obj x) (B.obj y)).obj (B.map f)
     let f3 := f1 ⋙ f2
     f3
-/

namespace FunctorOperation
section

open CategoryTheory.Functor

variable {Γ : Type u₂} [Groupoid.{v₂} Γ] (A B : Γ ⥤ Grpd.{v₁,u₁})

/--
The functor that, on objects `G : A.obj x ⥤ B.obj x` acts by
creating the map on the right,
by taking the inverse of `f : x ⟶ y` in the groupoid
         A f
  A x --------> A y
   |             .
   |             |
   |             .
G  |             | conjugating A B f G
   |             .
   V             V
  B x --------> B y
         B f
-/
def conjugating {x y : Γ} (f : x ⟶ y) : (A.obj x ⥤ B.obj x) ⥤ (A.obj y ⥤ B.obj y) :=
  whiskeringLeftObjWhiskeringRightObj (A.map (CategoryTheory.inv f)) (B.map f)

@[simp] lemma conjugating_obj {x y : Γ} (f : x ⟶ y) (s : A.obj x ⥤ B.obj x) :
    (conjugating A B f).obj s = CategoryTheory.inv (A.map f) ⋙ s ⋙ B.map f := by
  simp [conjugating]

@[simp] lemma conjugating_map {x y : Γ} (f : x ⟶ y) {s1 s2 : A.obj x ⥤ B.obj x} (h : s1 ⟶ s2) :
    (conjugating A B f).map h
    = whiskerRight (whiskerLeft (A.map (CategoryTheory.inv f)) h) (B.map f) := by
  simp [conjugating]

@[simp] lemma conjugating_id (x : Γ) : conjugating A B (𝟙 x) = 𝟭 _ := by
  simp [conjugating]

@[simp] lemma conjugating_comp (x y z : Γ) (f : x ⟶ y) (g : y ⟶ z) :
    conjugating A B (f ≫ g) = conjugating A B f ⋙ conjugating A B g := by
  simp [conjugating]

@[simp] lemma conjugating_naturality_map {Δ : Type u₃} [Groupoid.{v₃} Δ] (σ : Δ ⥤ Γ)
    {x y} (f : x ⟶ y) : conjugating (σ ⋙ A) (σ ⋙ B) f = conjugating A B (σ.map f) := by
  simp [conjugating]
end

section

variable {Γ : Type u₂} [Category.{v₂} Γ] {A : Γ ⥤ Grpd.{v₁,u₁}}
  (B : ∫(A) ⥤ Grpd.{v₁,u₁}) (x : Γ)

abbrev sigma.fstAuxObj : sigmaObj B x ⥤ A.obj x := forget

open sigma

def piObj : Grpd := Grpd.of (Section (fstAuxObj B x))

end

section
variable {Γ : Type u₂} [Groupoid.{v₂} Γ] (A : Γ ⥤ Grpd.{u₁,u₁}) (B : ∫(A) ⥤ Grpd.{u₁,u₁})
variable {x y : Γ} (f: x ⟶ y)

open sigma

/--
If `s : piObj B x` then the underlying functor is of the form `s : A x ⥤ sigma A B x`
and it is a section of the forgetful functor `sigma A B x ⥤ A x`.
This theorem states that conjugating `A f⁻¹ ⋙ s ⋙ sigma A B f⁻¹ : A y ⥤ sigma A B y`
using some `f : x ⟶ y` produces a section of the forgetful functor `sigma A B y ⥤ A y`.
-/
theorem isSection_conjugating_isSection (s : piObj B x) : IsSection (fstAuxObj B y)
    ((Section.ι (fstAuxObj B x) ⋙ conjugating A (sigma A B) f).obj s) := by
  simp only [IsSection, Functor.comp_obj, ObjectProperty.ι_obj,
    conjugating_obj, Functor.assoc]
  convert_to CategoryTheory.inv (A.map f) ⋙ (s.obj ⋙ fstAuxObj B x) ⋙ A.map f = _
  rw [s.property]
  simp only [Functor.id_comp, ← Grpd.comp_eq_comp, IsIso.inv_hom_id, Grpd.id_eq_id]

/-- The functorial action of `pi` on a morphism `f : x ⟶ y` in `Γ`
is given by "conjugation".
Since `piObj B x` is a full subcategory of `sigma A B x ⥤ A x`,
we obtain the action `piMap : piObj B x ⥤ piObj B y`
as the induced map in the following diagram
          the inclusion
           Section.ι
   piObj B x   ⥤   (A x ⥤ sigma A B x)
     ⋮                     ||
     ⋮                     || conjugating A (sigma A B) f
     VV                     VV
   piObj B y   ⥤   (A y ⥤ sigma A B y)
-/
def piMap : piObj B x ⥤ piObj B y :=
  ObjectProperty.lift (IsSection (fstAuxObj B y))
  ((Section.ι (fstAuxObj B x) ⋙ conjugating A (sigma A B) f))
  (isSection_conjugating_isSection A B f)

lemma piMap_obj_obj (s: piObj B x) : ((piMap A B f).obj s).obj =
    (conjugating A (sigma A B) f).obj s.obj := rfl

lemma piMap_map (s1 s2: piObj B x) (η: s1 ⟶ s2) :
    (piMap A B f).map η = (conjugating A (sigma A B) f).map η :=
  rfl

/--
The square commutes

   piObj B x   ⥤   (A x ⥤ sigma A B x)
     ⋮                     ||
piMap⋮                     || conjugating A (sigma A B) f
     VV                     VV
   piObj B y   ⥤   (A y ⥤ sigma A B y)
-/
lemma piMap_ι : piMap A B f ⋙ Section.ι (fstAuxObj B y)
    = Section.ι (fstAuxObj B x) ⋙ conjugating A (sigma A B) f :=
  rfl

@[simp] lemma piMap_id (x : Γ) : piMap A B (𝟙 x) = 𝟭 (piObj B x) := by
  simp only [piMap, conjugating_id]
  rfl

lemma piMap_comp {x y z : Γ} (f : x ⟶ y) (g : y ⟶ z) :
    piMap A B (f ≫ g) = (piMap A B f) ⋙ (piMap A B g) := by
  simp only [piMap, conjugating_comp]
  rfl

/-- The formation rule for Π-types for the natural model `smallU`
  as operations between functors -/
@[simps] def pi : Γ ⥤ Grpd.{u₁,u₁} where
  obj x := piObj B x
  map := piMap A B
  map_id := piMap_id A B
  map_comp := piMap_comp A B

end

section

variable {Γ : Type u₂} [Groupoid.{v₂} Γ] (A : Γ ⥤ Grpd.{u₁,u₁}) (B : ∫(A) ⥤ Grpd.{u₁,u₁})
  {Δ : Type u₃} [Groupoid.{v₃} Δ] (σ : Δ ⥤ Γ)

theorem IsSection_eq (x) : sigma.fstAuxObj B (σ.obj x)
    ≍ sigma.fstAuxObj (Grothendieck.Groupoidal.pre A σ ⋙ B) x := by
  dsimp [sigma.fstAuxObj, sigmaObj]
  rw [sigma_naturality_aux]

theorem pi_naturality_obj (x) :
    (σ ⋙ pi A B).obj x = (pi (σ ⋙ A) (pre A σ ⋙ B)).obj x := by
  dsimp [pi, piObj, sigma.fstAuxObj, sigmaObj]
  rw [sigma_naturality_aux]

lemma piObj_naturality (x):
  piObj B (σ.obj x) = piObj (Grothendieck.Groupoidal.pre A σ ⋙ B) x := by
  dsimp [pi, piObj, sigma.fstAuxObj, sigmaObj]
  rw [sigma_naturality_aux]




lemma eqToHom_eq_homOf_map' {Γ : Type*} [Groupoid Γ] {F G : Γ ⥤ Grpd} (h : F = G) :
    eqToHom (by rw [h]) = Grpd.homOf (map (eqToHom h)) := by
  subst h
  fapply CategoryTheory.Functor.ext
  · intro x
    apply obj_hext
    · simp
    · simp
  · intro x y f
    rw! [Grothendieck.Groupoidal.map_id_eq]
    simp


    /-
    Δ ------pi (σ ⋙ A) (pre A σ ⋙ B)-------> Grpd
    |                                           |
    |                                           |
    σ                                           |
    |                                           |
    v                                           v
    Γ -------pi A B -------------------------> Grpd

    -/



section

variable (x y : Δ )
lemma comp_obj_eq (x): A.obj (σ.obj x) = (σ ⋙ A).obj x := rfl

def funcEqWhisker1 (x) : (((σ ⋙ A).obj x) ⥤ sigmaObj (Grothendieck.Groupoidal.pre A σ ⋙ B) x)⥤
    (A.obj (σ.obj x)) ⥤ sigmaObj B (σ.obj x) :=
    (CategoryTheory.Functor.whiskeringRight _ _ _ ).obj
    (map (eqToHom (sigma_naturality_aux B σ x)))





-- lemma eqToHom_ι1 {x } :
--  eqToHom (pi_naturality_obj A B Δ σ x).symm ⋙
--  ObjectProperty.ι (IsSection (sigma.fstAuxObj B (σ.obj x))) =
--  ObjectProperty.ι (IsSection (sigma.fstAuxObj (Grothendieck.Groupoidal.pre A σ ⋙ B) x)) ⋙
--  funcEqWhisker1 A B Δ σ  (x) :=



--  sorry

lemma eqToHom_ι_aux :
    Grpd.of ((A.obj (σ.obj x)) ⥤ ∫(ι A (σ.obj x) ⋙ B))
    = Grpd.of (A.obj (σ.obj x) ⥤ ∫(ι (σ ⋙ A) x ⋙ pre A σ ⋙ B)) :=
  by rw [sigma_naturality_aux]

lemma ObjectProperty.eqToHom_comp_ι {C D : Grpd} (h : C = D) (P : ObjectProperty C)
    (Q : ObjectProperty D) (hP : P ≍ Q) :
    let h' : Grpd.of P.FullSubcategory = Grpd.of Q.FullSubcategory := by
      subst h hP; rfl
    eqToHom h' ⋙ (ObjectProperty.ι Q) = (ObjectProperty.ι P) ⋙ eqToHom h := by
  subst h hP; rfl

lemma eqToHom_ι (x) :
    eqToHom (pi_naturality_obj A B σ x) ⋙
    ObjectProperty.ι (IsSection (sigma.fstAuxObj (pre A σ ⋙ B) x)) =
    ObjectProperty.ι (IsSection (sigma.fstAuxObj B (σ.obj x))) ⋙
    eqToHom (eqToHom_ι_aux A B σ x) := by
  apply ObjectProperty.eqToHom_comp_ι (eqToHom_ι_aux A B σ x)
  dsimp [sigma.fstAuxObj, sigmaObj]
  rw [sigma_naturality_aux]

def funcEqWhisker :
    ((A.obj (σ.obj x)) ⥤ ∫(ι A (σ.obj x) ⋙ B)) -- parentheses here
    ⥤ (A.obj (σ.obj x)) ⥤ ∫(ι (σ ⋙ A) x ⋙ pre A σ ⋙ B) :=
    (Functor.whiskeringRight (A.obj (σ.obj x)) (∫(ι A (σ.obj x) ⋙ B)) ∫(ι (σ ⋙ A) x ⋙ pre A σ ⋙ B)).obj
     (map (eqToHom (sigma_naturality_aux B σ x).symm))
end

section
variable  {C : Type u} [Category.{v} C] {D : Type u₁} [Category.{v₁} D] (P Q : ObjectProperty D)
  (F : C ⥤ D) (hF : ∀ X, P (F.obj X))

theorem FullSubcategory.lift_comp_inclusion_eq :
    P.lift F hF ⋙ P.ι = F :=
  rfl

end


lemma eqToHom_conjugating {x y} (f : x ⟶ y):
    eqToHom (eqToHom_ι_aux A B σ x) ≫ conjugating (σ ⋙ A) (sigma (σ ⋙ A) (pre A σ ⋙ B)) f =
    conjugating A (sigma A B) (σ.map f) ≫ eqToHom (eqToHom_ι_aux A B σ y) := by
  conv => left; right; rw! (castMode := .all) [← sigma_naturality]
  simp only [Functor.comp_obj, conjugating_naturality_map]
  apply eq_of_heq
  rw [heq_comp_eqToHom_iff] -- HEq tactic please
  apply HEq.trans (eqToHom_comp_heq _ _)
  simp


lemma comm_sq_of_comp_mono {C : Type*} [Category C]
    {X Y Z W X' Y' Z' W' : C}
    (f : X ⟶ Y) (h : X ⟶ W) (g : Y ⟶ Z) (i : W ⟶ Z)
    (f' : X' ⟶ Y') (h' : X' ⟶ W') (g' : Y' ⟶ Z') (i' : W' ⟶ Z')
    (mX : X ⟶ X') (mY : Y ⟶ Y') (mW : W ⟶ W') (mZ : Z ⟶ Z')
    (hbot : f' ≫ g' = h' ≫ i')
    (hf : f ≫ mY = mX ≫ f')
    (hh : h ≫ mW = mX ≫ h')
    (hg : g ≫ mZ = mY ≫ g')
    (hi : i ≫ mZ = mW ≫ i')
    [e : Mono mZ]
    : f ≫ g = h ≫ i := by
  apply e.right_cancellation
  calc (f ≫ g) ≫ mZ
    _ = f ≫ g ≫ mZ := by aesop
    _ = f ≫ mY ≫ g' := by aesop
    _ = (f ≫ mY) ≫ g' := by simp
    _  = (mX ≫ f') ≫ g' := by aesop
    _  = mX ≫ f' ≫ g' := by simp
    _  = mX ≫ h' ≫ i' := by aesop
    _  = (mX ≫ h') ≫ i' := by simp
    _  = (h ≫ mW) ≫ i' := by aesop
    _  = h ≫ mW ≫ i' := by simp
    _  = h ≫ i ≫ mZ := by aesop
    _  = (h ≫ i) ≫ mZ := by aesop



theorem pi_naturality_map {x y} (f : x ⟶ y) :
    Grpd.homOf (piMap A B (σ.map f)) ≫ eqToHom (pi_naturality_obj A B σ y)
    = eqToHom (pi_naturality_obj A B σ x) ≫ (Grpd.homOf (piMap (σ ⋙ A) (pre A σ ⋙ B) f)) := by
  apply comm_sq_of_comp_mono (e := Grpd.ι_mono (Grpd.of (_ ⥤ _))
      (IsSection (sigma.fstAuxObj (Grothendieck.Groupoidal.pre A σ ⋙ B) y)))
    (Grpd.homOf (piMap A B (σ.map f)))
    (eqToHom (pi_naturality_obj A B σ x))
    (eqToHom (pi_naturality_obj A B σ y)) (Grpd.homOf (piMap (σ ⋙ A) (pre A σ ⋙ B) f))
    (Grpd.homOf (conjugating A (sigma A B) (σ.map f)))
    (eqToHom (eqToHom_ι_aux A B σ x)) (eqToHom (eqToHom_ι_aux A B σ y))
    (Grpd.homOf (conjugating (σ ⋙ A) (sigma (σ ⋙ A) (pre A σ ⋙ B)) f))
    (Grpd.homOf (ObjectProperty.ι _))
    (Grpd.homOf (ObjectProperty.ι _))
    (Grpd.homOf (ObjectProperty.ι _))
    (Grpd.homOf (ObjectProperty.ι _))
  · rw [eqToHom_conjugating]
  · apply FunctorOperation.FullSubcategory.lift_comp_inclusion_eq
  · apply eqToHom_ι
  · apply eqToHom_ι
  · apply FunctorOperation.FullSubcategory.lift_comp_inclusion_eq

theorem pi_naturality : σ ⋙ pi A B = pi (σ ⋙ A) (pre A σ ⋙ B) := by
  fapply CategoryTheory.Functor.ext
  · apply pi_naturality_obj
  · intro x y f
    erw [← Category.assoc, ← pi_naturality_map]
    simp [- Grpd.comp_eq_comp, - Grpd.id_eq_id]

end



namespace pi

variable {Γ : Type u₂} [Groupoid.{v₂} Γ] {A : Γ ⥤ Grpd.{u₁,u₁}} (B : ∫(A) ⥤ Grpd.{u₁,u₁})
  (f : Γ ⥤ PGrpd.{u₁,u₁}) (hf : f ⋙ PGrpd.forgetToGrpd = pi A B)

-- -- NOTE: it seems like we need a 2-categorical version of Grothendieck.map
-- -- so the following should be replaced with something like
-- -- `secAux : CategoryTheory.Oplax.OplaxTrans A (sigma A B)`
-- def secAux : A ⟶ sigma A B where
--   app x := (PGrpd.objFiber' hf x).obj
--   naturality x y g := by
--     have h : (((pi A B).map g).obj (PGrpd.objFiber' hf x)).obj ⟶ (PGrpd.objFiber' hf y).obj :=
--       PGrpd.mapFiber' hf g
--     simp [piMap_obj_obj] at h
--     simp

--     sorry

-- def secFib (x) : A.obj x ⥤ ∫(sigma A B) := (PGrpd.objFiber' hf x).obj ⋙ ι (sigma A B) x

-- def secHom {x y} (g : x ⟶ y) : secFib B f hf x ⟶ A.map g ⋙ secFib B f hf y := by
--   have h : (((pi A B).map g).obj (PGrpd.objFiber' hf x)).obj ⟶ (PGrpd.objFiber' hf y).obj :=
--       PGrpd.mapFiber' hf g
--   simp [piMap_obj_obj] at h
--   simp [secFib]
--   sorry

-- NOTE: this should be defined as something like `Grothendieck.Groupoidal.mapOplax secAux`
def sec : ∫(A) ⥤ ∫(sigma A B) :=
  map sorry
  -- have h (x) := (PGrpd.objFiber' hf x).obj
  -- exact functorTo forget (fun x => (h x.base).obj x.fiber) sorry sorry sorry
  -- exact functorFrom (secFib B f hf) (fun {x y} g => sorry) sorry sorry

/--  Let `Γ` be a category.
For any pair of functors `A : Γ ⥤ Grpd` and `B : ∫(A) ⥤ Grpd`,
and any "term of pi", meaning a functor `f : Γ ⥤ PGrpd`
satisfying `f ⋙ forgetToGrpd = pi A B : Γ ⥤ Grpd`,
there is a "term of `B`" `sec' : Γ ⥤ PGrpd` such that `sec' ⋙ forgetToGrpd = B`.
-/
def sec' : ∫(A) ⥤ PGrpd := sorry ⋙ sigma.assoc B ⋙ toPGrpd B

def sec_forgetToGrpd : sec' B ⋙ PGrpd.forgetToGrpd = B := sorry

end pi

section

variable {Γ : Type u₂} [Groupoid.{v₂} Γ] (A : Γ ⥤ Grpd.{u₁,u₁}) (β : ∫(A) ⥤ PGrpd.{u₁,u₁})

section
variable (x : Γ)

def lamFibObjObj : Grpd.of (A.obj x ⥤ sigmaObj (β ⋙ PGrpd.forgetToGrpd) x) :=
  sec (ι A x ⋙ β ⋙ PGrpd.forgetToGrpd) (ι A x ⋙ β) rfl

@[simp] lemma lamFibObjObj_obj_base (a) : ((lamFibObjObj A β x).obj a).base = a := by
  simp [lamFibObjObj]

@[simp] lemma lamFibObjObj_obj_fiber (a) : ((lamFibObjObj A β x).obj a).fiber
    = PGrpd.objFiber (ι A x ⋙ β) a := by
  simp [lamFibObjObj]

@[simp] lemma lamFibObjObj_map_base {a a'} (h: a ⟶ a'):
    ((lamFibObjObj A β x).map h).base = h := by
  simp [lamFibObjObj]

@[simp] lemma lamFibObjObj_map_fiber {a a'} (h: a ⟶ a'):
    ((lamFibObjObj A β x).map h).fiber = PGrpd.mapFiber (ι A x ⋙ β) h := by
  simp [lamFibObjObj]

def lamFibObj : piObj (β ⋙ PGrpd.forgetToGrpd) x :=
  ⟨lamFibObjObj A β x , rfl⟩

@[simp] lemma lamFibObj_obj : (lamFibObj A β x).obj = lamFibObjObj A β x :=
  rfl

@[simp] lemma lamFibObj_obj_obj : (lamFibObj A β x).obj = lamFibObjObj A β x :=
  rfl

end

section
variable {x y : Γ} (f : x ⟶ y)

open CategoryTheory.Functor

def lamFibObjObjCompSigmaMap.app (a : A.obj x) :
    (lamFibObjObj A β x ⋙ sigmaMap (β ⋙ PGrpd.forgetToGrpd) f).obj a ⟶
    (A.map f ⋙ lamFibObjObj A β y).obj a :=
  homMk (𝟙 _) (eqToHom (by simp; rfl) ≫ (β.map ((ιNatTrans f).app a)).fiber)

@[simp] lemma lamFibObjObjCompSigmaMap.app_base (a : A.obj x) : (app A β f a).base = 𝟙 _ := by
  simp [app]

lemma lamFibObjObjCompSigmaMap.app_fiber_eq (a : A.obj x) : (app A β f a).fiber =
    eqToHom (by simp; rfl) ≫ (β.map ((ιNatTrans f).app a)).fiber := by
  simp [app]

lemma lamFibObjObjCompSigmaMap.app_fiber_heq (a : A.obj x) : (app A β f a).fiber ≍
    (β.map ((ιNatTrans f).app a)).fiber := by
  simp [app]

lemma lamFibObjObjCompSigmaMap.naturality {x y : Γ} (f : x ⟶ y) {a1 a2 : A.obj x} (h : a1 ⟶ a2) :
    (lamFibObjObj A β x ⋙ sigmaMap (β ⋙ PGrpd.forgetToGrpd) f).map h
    ≫ lamFibObjObjCompSigmaMap.app A β f a2 =
    lamFibObjObjCompSigmaMap.app A β f a1
    ≫ (A.map f ⋙ lamFibObjObj A β y).map h := by
  apply Grothendieck.Groupoidal.hext
  · simp [sigmaObj]
  · have β_ιNatTrans_naturality : β.map ((ι A x).map h) ≫ β.map ((ιNatTrans f).app a2)
        = β.map ((ιNatTrans f).app a1) ≫ β.map ((A.map f ⋙ ι A y).map h) := by
      simp [← Functor.map_comp, (ιNatTrans f).naturality h]
    have h_naturality : (β.map ((ιNatTrans f).app a2)).base.map (β.map ((ι A x).map h)).fiber
        ≫ (β.map ((ιNatTrans f).app a2)).fiber ≍
        (β.map ((ι A y).map ((A.map f).map h))).base.map (β.map ((ιNatTrans f).app a1)).fiber
        ≫ (β.map ((ι A y).map ((A.map f).map h))).fiber := by
      simpa [← heq_eq_eq] using Grothendieck.congr β_ιNatTrans_naturality
    simp only [sigmaObj, Grpd.coe_of, comp_obj, Grothendieck.forget_obj,
      sigmaMap_obj_base, Functor.comp_map, comp_base, sigmaMap_map_base, Grothendieck.forget_map,
      sigmaMap_obj_fiber, comp_fiber, sigmaMap_map_fiber, lamFibObjObj_map_fiber, map_comp,
      eqToHom_map, app_fiber_eq, Category.assoc, eqToHom_trans_assoc,
      heq_eqToHom_comp_iff, eqToHom_comp_heq_iff]
    rw [← Category.assoc]
    apply HEq.trans _ h_naturality
    apply heq_comp _ rfl rfl _ HEq.rfl
    · aesop_cat
    · simp only [← Functor.comp_map, ← Grpd.comp_eq_comp, comp_eqToHom_heq_iff]
      congr 3
      aesop_cat

@[simp] lemma lamFibObjObjCompSigmaMap.app_id (a) : lamFibObjObjCompSigmaMap.app A β (𝟙 x) a
    = eqToHom (by simp) := by
  apply Grothendieck.Groupoidal.hext
  · simp [sigmaObj]
  · simp only [Grpd.forgetToCat.eq_1, sigmaObj, comp_obj, Grothendieck.forget_obj,
      sigmaMap_obj_base, app, Functor.comp_map, Grothendieck.forget_map, sigmaMap_obj_fiber, Cat.of_α,
      id_eq, homMk_base, homMk_fiber, eqToHom_comp_heq_iff]
    rw! (castMode := .all) [ιNatTrans_id_app]
    simp only [Grpd.coe_of, comp_obj, Grothendieck.congr (eqToHom_map β _),
      Grothendieck.fiber_eqToHom, eqToHom_trans, eqToHom_fiber,
      Grothendieck.forget_obj, sigmaMap_obj_base, Functor.comp_map, Grothendieck.forget_map,
      sigmaMap_obj_fiber, heq_eqRec_iff_heq]
    apply (eqToHom_heq_id_cod _ _ _).trans (eqToHom_heq_id_cod _ _ _).symm

lemma lamFibObjObjCompSigmaMap.app_comp {x y z : Γ} (f : x ⟶ y) (g : y ⟶ z) (a) :
    lamFibObjObjCompSigmaMap.app A β (f ≫ g) a
    = eqToHom (by simp)
    ≫ (sigmaMap (β ⋙ PGrpd.forgetToGrpd) g).map (app A β f a)
    ≫ app A β g ((A.map f).obj a) ≫ eqToHom (by simp) := by
  fapply Grothendieck.Groupoidal.ext
  · simp [sigmaObj]
  · have h : (β.map ((ιNatTrans (f ≫ g)).app a)) = β.map ((ιNatTrans f).app a)
      ≫ β.map ((ιNatTrans g).app ((A.map f).obj a))
      ≫ eqToHom (by simp) := by
      simp [ιNatTrans_comp_app]
    simp only [Grpd.forgetToCat.eq_1, sigmaObj, Grpd.coe_of, comp_obj, Grothendieck.forget_obj,
      sigmaMap_obj_base, app, Functor.comp_map, Grothendieck.forget_map, sigmaMap_obj_fiber,
      Cat.of_α, id_eq, comp_base, sigmaMap_map_base, homMk_base, homMk_fiber, Grothendieck.congr h,
      Grothendieck.comp_base, Grpd.comp_eq_comp, Grothendieck.comp_fiber, eqToHom_refl,
      Grothendieck.fiber_eqToHom, Category.id_comp, eqToHom_trans_assoc, comp_fiber, eqToHom_fiber,
      eqToHom_map, sigmaMap_map_fiber, map_comp, Category.assoc]
    rw! [Grothendieck.eqToHom_base, Category.id_comp, eqToHom_base, eqToHom_base, eqToHom_map,
      eqToHom_map, eqToHom_map, Grothendieck.eqToHom_base]
    aesop_cat

/-
a ---h---> a' in A.obj x

B(x,a) ----> B(y,Afa)
 |               |
 |               |
 v               v
B(x,a')----> B(y,Afa')
-/

def lamFibObjObjCompSigmaMap :
    lamFibObjObj A β x ⋙ sigmaMap (β ⋙ PGrpd.forgetToGrpd) f ⟶
    A.map f ⋙ lamFibObjObj A β y where
  app := lamFibObjObjCompSigmaMap.app A β f
  naturality _ _ h := lamFibObjObjCompSigmaMap.naturality A β f h

@[simp] lemma lamFibObjObjCompSigmaMap_id (x : Γ) : lamFibObjObjCompSigmaMap A β (𝟙 x) =
    eqToHom (by simp [sigmaMap_id]) := by
  ext a
  simp [lamFibObjObjCompSigmaMap]

/-
lamFibObjObj A β x ⋙ sigmaMap (β ⋙ PGrpd.forgetToGrpd) (f ≫ g)

_ ⟶ lamFibObjObj A β x ⋙ sigmaMap (β ⋙ PGrpd.forgetToGrpd) f ⋙ sigmaMap (β ⋙ PGrpd.forgetToGrpd) g
:= eqToHom ⋯

_ ⟶ A.map f ⋙ lamFibObjObj A β y ⋙ sigmaMap (β ⋙ PGrpd.forgetToGrpd) g
:= whiskerRight (lamFibObjObjCompSigmaMap A β f) (sigmaMap (β ⋙ PGrpd.forgetToGrpd) g)

_ ⟶ A.map f ⋙ A.map g ⋙ lamFibObjObj A β z
:= whiskerLeft (A.map f) (lamFibObjObjCompSigmaMap A β g)

_ ⟶ A.map (f ≫ g) ⋙ lamFibObjObj A β z
:= eqToHom ⋯

-/

lemma lamFibObjObjCompSigmaMap_comp {x y z : Γ} (f : x ⟶ y) (g : y ⟶ z) :
    lamFibObjObjCompSigmaMap A β (f ≫ g) =
    eqToHom (by rw [sigmaMap_comp]; rfl)
    ≫ whiskerRight (lamFibObjObjCompSigmaMap A β f) (sigmaMap (β ⋙ PGrpd.forgetToGrpd) g)
    ≫ whiskerLeft (A.map f) (lamFibObjObjCompSigmaMap A β g)
    ≫ eqToHom (by rw [Functor.map_comp, Grpd.comp_eq_comp, Functor.assoc]) := by
  ext a
  simp [lamFibObjObjCompSigmaMap, lamFibObjObjCompSigmaMap.app_comp]

def whiskerLeftInvLamObjObjSigmaMap :
    A.map (CategoryTheory.inv f) ⋙ lamFibObjObj A β x ⋙ sigmaMap (β ⋙ PGrpd.forgetToGrpd) f ⟶
    lamFibObjObj A β y :=
  whiskerLeft (A.map (CategoryTheory.inv f)) (lamFibObjObjCompSigmaMap A β f)
  ≫ eqToHom (by simp [← Grpd.comp_eq_comp])

@[simp] lemma whiskerLeftInvLamObjObjSigmaMap_id (x : Γ) :
    whiskerLeftInvLamObjObjSigmaMap A β (𝟙 x) = eqToHom (by simp [sigmaMap_id]) := by
  simp [whiskerLeftInvLamObjObjSigmaMap]

-- TODO find a better proof. This should not need `ext`,
-- instead should be by manipulating whiskerLeft and whiskerRight lemmas
lemma whiskerLeftInvLamObjObjSigmaMap_comp {x y z} (f : x ⟶ y) (g : y ⟶ z) :
    whiskerLeftInvLamObjObjSigmaMap A β (f ≫ g)
    = eqToHom (by simp [Functor.assoc, sigmaMap_comp])
    ≫ whiskerRight (whiskerLeft (A.map (CategoryTheory.inv g)) (whiskerLeftInvLamObjObjSigmaMap A β f))
      (sigmaMap (β ⋙ PGrpd.forgetToGrpd) g)
    ≫ whiskerLeftInvLamObjObjSigmaMap A β g := by
  simp only [whiskerLeftInvLamObjObjSigmaMap, lamFibObjObjCompSigmaMap_comp]
  rw! [Functor.map_inv, Functor.map_inv, Functor.map_inv,
    Functor.map_comp, IsIso.inv_comp]
  ext
  simp only [Grpd.forgetToCat.eq_1, sigmaObj, Grpd.comp_eq_comp, comp_obj, eqToHom_refl,
    Category.comp_id, whiskerLeft_comp, whiskerLeft_eqToHom, whiskerLeft_twice, Category.assoc,
    NatTrans.comp_app, eqToHom_app, whiskerLeft_app, whiskerRight_app, associator_inv_app,
    associator_hom_app, Category.id_comp, whiskerRight_comp, eqToHom_whiskerRight, map_id]
  congr 2
  simp only [← comp_obj, Functor.assoc]
  simp only [← Grpd.comp_eq_comp]
  rw! (castMode := .all) [IsIso.inv_hom_id]
  apply eq_of_heq
  simp [- heq_eq_eq]
  rfl

def lamFibMap :
    ((pi A (β ⋙ PGrpd.forgetToGrpd)).map f).obj (lamFibObj A β x) ⟶ lamFibObj A β y :=
  whiskerLeftInvLamObjObjSigmaMap A β f

@[simp] lemma lamFibMap_id (x : Γ) : lamFibMap A β (𝟙 x) = eqToHom (by simp) := by
  simp [lamFibMap]
  rfl

lemma lamFibMap_comp {x y z} (f : x ⟶ y) (g : y ⟶ z) :
    lamFibMap A β (f ≫ g)
    = eqToHom (by rw [← Functor.comp_obj]; apply Functor.congr_obj; simp [piMap_comp])
    ≫ ((piMap A (β ⋙ PGrpd.forgetToGrpd)) g).map ((lamFibMap A β) f)
    ≫ lamFibMap A β g := by
  simp [lamFibMap, piMap, whiskerLeftInvLamObjObjSigmaMap_comp]
  rfl

def lam : Γ ⥤ PGrpd.{u₁,u₁} :=
  PGrpd.functorTo
  (pi A (β ⋙ PGrpd.forgetToGrpd))
  (lamFibObj A β)
  (lamFibMap A β)
  (lamFibMap_id A β)
  (lamFibMap_comp A β)

lemma lam_comp_forgetToGrpd : lam A β ⋙ PGrpd.forgetToGrpd = pi A (β ⋙ PGrpd.forgetToGrpd) :=
  rfl

variable {Δ : Type u₃} [Groupoid.{v₃} Δ] (σ : Δ ⥤ Γ)

lemma lam_naturality_aux (x) :
    ι A (σ.obj x) ⋙ β ⋙ PGrpd.forgetToGrpd = ι (σ ⋙ A) x ⋙ pre A σ ⋙ β ⋙ PGrpd.forgetToGrpd := by
  simp [← Functor.assoc, ← Grothendieck.Groupoidal.ι_pre]

lemma lamFibObjObj_naturality (x) :
    lamFibObjObj A β (σ.obj x) ≍ lamFibObjObj (σ ⋙ A) (pre A σ ⋙ β) x := by
  simp only [lamFibObjObj, ← ι_pre, comp_obj, Functor.assoc]
  congr!

lemma lam_naturality_obj_aux (x) :
    Grpd.of (A.obj (σ.obj x) ⥤ sigmaObj (β ⋙ PGrpd.forgetToGrpd) (σ.obj x)) ≍
    Grpd.of (A.obj (σ.obj x) ⥤ sigmaObj ((pre A σ ⋙ β) ⋙ PGrpd.forgetToGrpd) x) := by
  rw [sigmaObj_naturality, Functor.assoc]

theorem lam_naturality_obj (x : Δ) : HEq (lamFibObj A β (σ.obj x))
    (lamFibObj (σ ⋙ A) (Grothendieck.Groupoidal.pre A σ ⋙ β) x) := by
  simp only [lamFibObj]
  apply Grpd.ObjectProperty.FullSubcategory.hext (lam_naturality_obj_aux A β σ x)
  · simp only [sigma.fstAuxObj, Functor.assoc]
    congr!
    any_goals simp [sigmaObj_naturality, lam_naturality_aux]
  · apply lamFibObjObj_naturality

lemma lamFibObjObjCompSigmaMap.app_naturality {x y} (f : x ⟶ y) (a) :
    lamFibObjObjCompSigmaMap.app A β (σ.map f) a ≍
    lamFibObjObjCompSigmaMap.app (σ ⋙ A) (pre A σ ⋙ β) f a := by
  apply Grothendieck.Groupoidal.hext'
  any_goals apply Grpd.Functor.hcongr_obj
  any_goals apply Grpd.comp_hcongr
  any_goals simp only [comp_obj, Functor.comp_map, heq_eq_eq]
  any_goals apply sigmaObj_naturality
  any_goals apply lam_naturality_aux
  any_goals apply sigmaMap_naturality_heq
  any_goals apply lamFibObjObj_naturality
  any_goals simp [app]; rfl

lemma lamFibObjObjCompSigmaMap_naturality {x y} (f : x ⟶ y) :
    lamFibObjObjCompSigmaMap A β (σ.map f) ≍
    lamFibObjObjCompSigmaMap (σ ⋙ A) (pre A σ ⋙ β) f := by
  apply Grpd.NatTrans.hext
  any_goals apply Grpd.comp_hcongr
  any_goals simp only [comp_obj, Functor.comp_map, heq_eq_eq, eqToHom_refl]
  any_goals apply sigmaObj_naturality
  any_goals apply lamFibObjObj_naturality
  · apply sigmaMap_naturality_heq
  · apply lamFibObjObjCompSigmaMap.app_naturality

lemma whiskerLeftInvLamObjObjSigmaMap_naturality_heq {x y} (f : x ⟶ y) :
    whiskerLeftInvLamObjObjSigmaMap A β (σ.map f) ≍
    whiskerLeftInvLamObjObjSigmaMap (σ ⋙ A) (pre A σ ⋙ β) f := by
  simp only [whiskerLeftInvLamObjObjSigmaMap, Functor.comp_map]
  apply HEq.trans (comp_eqToHom_heq _ _)
  apply HEq.trans _ (comp_eqToHom_heq _ _).symm
  rw [Functor.map_inv, Functor.map_inv, Functor.map_inv]
  apply Grpd.whiskerLeft_hcongr_right
  any_goals apply Grpd.comp_hcongr
  any_goals simp only [comp_obj, heq_eq_eq]
  any_goals apply sigmaObj_naturality
  any_goals apply lamFibObjObj_naturality
  · apply sigmaMap_naturality_heq
  · apply lamFibObjObjCompSigmaMap_naturality

lemma lam_naturality_map {x y} (f : x ⟶ y) :
    lamFibMap A β (σ.map f) ≍ lamFibMap (σ ⋙ A) (Grothendieck.Groupoidal.pre A σ ⋙ β) f := by
  apply whiskerLeftInvLamObjObjSigmaMap_naturality_heq

theorem lam_naturality : σ ⋙ lam A β = lam (σ ⋙ A) (pre A σ ⋙ β)
     := by
  apply PGrpd.Functor.hext
  · apply pi_naturality
  · apply lam_naturality_obj
  · apply lam_naturality_map

end
end

section
variable {Γ : Ctx}

namespace smallUPi

def Pi_app (AB : y(Γ) ⟶ smallU.{v}.Ptp.obj smallU.{v}.Ty) :
    y(Γ) ⟶ smallU.{v}.Ty :=
  yonedaCategoryEquiv.symm (pi _ (smallU.PtpEquiv.snd AB))

def Pi_naturality {Δ Γ} (f : Δ ⟶ Γ) (α : y(Γ) ⟶ smallU.Ptp.obj smallU.Ty) :
    Pi_app (ym(f) ≫ α) = ym(f) ≫ Pi_app α := by
  dsimp only [Pi_app]
  rw [← yonedaCategoryEquiv_symm_naturality_left, pi_naturality,
    smallU.PtpEquiv.snd_naturality]
  rw! [smallU.PtpEquiv.fst_naturality]
  simp [map_id_eq, Functor.id_comp]

/-- The formation rule for Π-types for the natural model `smallU` -/
def Pi : smallU.{v}.Ptp.obj smallU.{v}.Ty ⟶ smallU.{v}.Ty :=
  NatTrans.yonedaMk Pi_app Pi_naturality

lemma Pi_app_eq {Γ : Ctx} (ab : y(Γ) ⟶ _) : ab ≫ Pi =
    yonedaCategoryEquiv.symm (FunctorOperation.pi _ (smallU.PtpEquiv.snd ab)) := by
  rw [Pi, NatTrans.yonedaMk_app, Pi_app]

def lam_app (ab : y(Γ) ⟶ smallU.{v}.Ptp.obj smallU.{v}.Tm) :
    y(Γ) ⟶ smallU.{v}.Tm :=
  yonedaCategoryEquiv.symm (lam _ (smallU.PtpEquiv.snd ab))

open smallU.PtpEquiv

def lam_naturality {Δ Γ} (f : Δ ⟶ Γ) (α : y(Γ) ⟶ smallU.Ptp.obj smallU.Tm) :
    lam_app (ym(f) ≫ α) = ym(f) ≫ lam_app α := by
  dsimp only [lam_app]
  rw [← yonedaCategoryEquiv_symm_naturality_left, FunctorOperation.lam_naturality]
  rw! [snd_naturality, fst_naturality]
  simp [map_id_eq]

/-- The introduction rule for Π-types for the natural model `smallU` -/
def lam : smallU.{v}.Ptp.obj smallU.{v}.Tm ⟶ smallU.{v}.Tm :=
  NatTrans.yonedaMk lam_app lam_naturality

lemma lam_app_eq {Γ : Ctx} (ab : y(Γ) ⟶ smallU.Ptp.obj smallU.Tm) : ab ≫ lam =
    yonedaCategoryEquiv.symm (FunctorOperation.lam _ (smallU.PtpEquiv.snd ab)) := by
  rw [lam, NatTrans.yonedaMk_app, lam_app]

lemma smallU.PtpEquiv.fst_app_comp_map_tp {Γ : Ctx} (ab : y(Γ) ⟶ smallU.Ptp.obj smallU.Tm) :
    smallU.PtpEquiv.fst (ab ≫ smallU.Ptp.map smallU.tp) = smallU.PtpEquiv.fst ab :=
  sorry

lemma smallU.PtpEquiv.snd_app_comp_map_tp {Γ : Ctx} (ab : y(Γ) ⟶ smallU.Ptp.obj smallU.Tm) :
    smallU.PtpEquiv.snd (ab ≫ smallU.Ptp.map smallU.tp)
    ≍ smallU.PtpEquiv.snd ab ⋙ PGrpd.forgetToGrpd :=
  sorry

theorem lam_tp : smallUPi.lam ≫ smallU.tp = smallU.Ptp.map smallU.tp ≫ Pi := by
  apply hom_ext_yoneda
  intros Γ ab
  rw [← Category.assoc, ← Category.assoc, lam_app_eq, Pi_app_eq, smallU_tp, π,
    ← yonedaCategoryEquiv_symm_naturality_right, lam_comp_forgetToGrpd]
  symm; congr 2
  · apply smallU.PtpEquiv.fst_app_comp_map_tp
  · apply smallU.PtpEquiv.snd_app_comp_map_tp

section
variable {Γ : Ctx} (AB : y(Γ) ⟶ smallU.Ptp.obj.{v} y(U.{v}))
  (αβ : y(Γ) ⟶ y(E.{v})) (hαβ : αβ ≫ ym(π) = AB ≫ smallUPi.Pi)

include hαβ in
theorem yonedaCategoryEquiv_forgetToGrpd : yonedaCategoryEquiv αβ ⋙ PGrpd.forgetToGrpd
    = pi (smallU.PtpEquiv.fst AB) (smallU.PtpEquiv.snd AB) := by
  erw [← yonedaCategoryEquiv_naturality_right, hαβ]
  rw [smallUPi.Pi_app_eq, yonedaCategoryEquiv.apply_symm_apply]

def lift : y(Γ) ⟶ smallU.Ptp.obj.{v} smallU.Tm.{v} :=
  let αβ' := yonedaCategoryEquiv αβ
  smallU.PtpEquiv.mk (smallU.PtpEquiv.fst AB) sorry

  -- let β' := smallU.PtpEquiv.snd AB
  -- let αβ' := yonedaCategoryEquiv αβ
  -- let hαβ' : yonedaCategoryEquiv αβ ⋙ forgetToGrpd
  --   = sigma (smallU.PtpEquiv.fst AB) (smallU.PtpEquiv.snd AB) :=
  --   yonedaCategoryEquiv_forgetToGrpd _ _ hαβ
  -- mk (sigma.fst' β' αβ' hαβ') (sigma.dependent' β' αβ' hαβ')
  -- (sigma.snd' β' αβ' hαβ') (sigma.snd'_forgetToGrpd β' αβ' hαβ')

-- theorem fac_left : lift.{v} AB αβ hαβ ≫ smallUSigma.pair.{v} = αβ := by
--   rw [smallUSigma.pair_app_eq]
--   dsimp only [lift]
--   rw! [dependent_mk, snd_mk, fst_mk]
--   simp only [eqToHom_refl, map_id_eq, Cat.of_α, Functor.id_comp]
--   rw [yonedaCategoryEquiv.symm_apply_eq, sigma.eta]

-- theorem fac_right : lift.{v} AB αβ hαβ ≫ smallU.comp.{v} = AB := by
--   apply smallU.PtpEquiv.hext
--   · rw [← fst_forgetToGrpd]
--     dsimp only [lift]
--     rw [fst_mk, sigma.fst'_forgetToGrpd]
--   · apply HEq.trans (dependent_heq _).symm
--     rw [lift, dependent_mk]
--     dsimp [sigma.dependent']
--     simp [map_id_eq, Functor.id_comp]
--     apply map_eqToHom_comp_heq

-- theorem hom_ext (m n : y(Γ) ⟶ smallU.compDom.{v})
--     (hComp : m ≫ smallU.comp = n ≫ smallU.comp)
--     (hPair : m ≫ smallUSigma.pair = n ≫ smallUSigma.pair) : m = n := sorry

-- theorem uniq (m : y(Γ) ⟶ smallU.compDom)
--     (hmAB : m ≫ smallU.comp = AB) (hmαβ : m ≫ smallUSigma.pair = αβ) :
--     m = lift AB αβ hαβ := by
--   apply hom_ext
--   · rw [hmAB, fac_right]
--   · rw [hmαβ, fac_left]

end
theorem isPullback : IsPullback lam.{v,u} (smallU.Ptp.{v,u}.map smallU.tp)
    smallU.{v, u}.tp Pi.{v, u} :=
  Limits.RepPullbackCone.is_pullback lam_tp
    (fun s => sorry)
    (fun s => sorry)
    (fun s => sorry)
    (fun s m fac_left fac_right => sorry)
  -- Limits.RepPullbackCone.is_pullback smallUSigma.lam_tp.{v,u}
  --   (fun s => lift s.snd s.fst s.condition)
  --   (fun s => fac_left.{v,u} _ _ s.condition)
  --   (fun s => fac_right.{v,u} _ _ s.condition)
  --   (fun s m fac_left fac_right => uniq.{v,u} _ _ s.condition m fac_right fac_left)

end smallUPi

def smallUPi : NaturalModelPi smallU.{v} where
  Pi := smallUPi.Pi.{v}
  lam := smallUPi.lam.{v}
  Pi_pullback := sorry

def uHomSeqPis' (i : ℕ) (ilen : i < 4) :
  NaturalModelPi (uHomSeqObjs i ilen) :=
  match i with
  | 0 => smallUPi.{0,4}
  | 1 => smallUPi.{1,4}
  | 2 => smallUPi.{2,4}
  | 3 => smallUPi.{3,4}
  | (n+4) => by omega

def uHomSeqPis : UHomSeqPiSigma Ctx := { uHomSeq with
  nmPi := uHomSeqPis'
  nmSigma := uHomSeqSigmas' }

end

end FunctorOperation

end GroupoidModel
