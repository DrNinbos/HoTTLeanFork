import GroupoidModel.ForMathlib


namespace CategoryTheory.Functor

structure Iso (C D : Type*) [Category C] [Category D] where
  hom : C ⥤ D
  inv : D ⥤ C
  hom_inv_id : hom ⋙ inv = 𝟭 _  := by aesop_cat
  inv_hom_id : inv ⋙ hom = 𝟭 _  := by aesop_cat

/-- Notation for an isomorphism in a category. -/
infixr:10 " ≅≅ " => Iso -- type as \cong or \iso

variable {X Y Z : Type*} [Category X] [Category Y] [Category Z]

namespace Iso

@[simp] lemma hom_inv_id' (I : X ≅≅ Y) : I.hom ⋙ I.inv = 𝟭 _ := I.hom_inv_id

@[simp] lemma inv_hom_id' (I : X ≅≅ Y) : I.inv ⋙ I.hom = 𝟭 _ := I.inv_hom_id

@[ext]
theorem ext ⦃α β : X ≅≅ Y⦄ (w : α.hom = β.hom) : α = β :=
  suffices α.inv = β.inv by
    cases α
    cases β
    cases w
    cases this
    rfl
  calc
    α.inv = α.inv ⋙ β.hom ⋙ β.inv   := by rw [Iso.hom_inv_id, Functor.comp_id]
    _     = (α.inv ⋙ α.hom) ⋙ β.inv := by rw [Functor.assoc, ← w]
    _     = β.inv                    := by rw [Iso.inv_hom_id, Functor.id_comp]

/-- Inverse isomorphism. -/
@[symm]
def symm (I : X ≅≅ Y) : Y ≅≅ X where
  hom := I.inv
  inv := I.hom
  hom_inv_id := I.inv_hom_id
  inv_hom_id := I.hom_inv_id

@[simp]
theorem symm_hom (α : X ≅≅ Y) : α.symm.hom = α.inv :=
  rfl

@[simp]
theorem symm_inv (α : X ≅≅ Y) : α.symm.inv = α.hom :=
  rfl

@[simp]
theorem symm_mk (hom : X ⥤ Y) (inv : Y ⥤ X) (hom_inv_id) (inv_hom_id) :
    Iso.symm { hom, inv, hom_inv_id := hom_inv_id, inv_hom_id := inv_hom_id } =
      { hom := inv, inv := hom, hom_inv_id := inv_hom_id, inv_hom_id := hom_inv_id } :=
  rfl

@[simp]
theorem symm_symm_eq (α : X ≅≅ Y) : α.symm.symm = α := rfl

theorem symm_bijective : Function.Bijective (symm : (X ≅≅ Y) → _) :=
  Function.bijective_iff_has_inverse.mpr ⟨_, symm_symm_eq, symm_symm_eq⟩

@[simp]
theorem symm_eq_iff {α β : X ≅≅ Y} : α.symm = β.symm ↔ α = β :=
  symm_bijective.injective.eq_iff

variable (X) (Y) in
theorem nonempty_iso_symm : Nonempty (X ≅≅ Y) ↔ Nonempty (Y ≅≅ X) :=
  ⟨fun h => ⟨h.some.symm⟩, fun h => ⟨h.some.symm⟩⟩

variable (X) in
/-- Identity isomorphism. -/
@[refl, simps]
def refl : X ≅≅ X where
  hom := Functor.id X
  inv := Functor.id X

instance : Inhabited (X ≅≅ X) := ⟨Iso.refl X⟩

variable (X) in
theorem nonempty_iso_refl : Nonempty (X ≅≅ X) := ⟨default⟩

variable (X) in
@[simp]
theorem refl_symm : (Iso.refl X).symm = Iso.refl X := rfl

/-- Composition of two isomorphisms -/
@[simps]
def trans (α : X ≅≅ Y) (β : Y ≅≅ Z) : X ≅≅ Z where
  hom := α.hom ⋙ β.hom
  inv := β.inv ⋙ α.inv
  hom_inv_id := sorry
  inv_hom_id := sorry

/-- Notation for composition of isomorphisms. -/
infixr:80 " ≪⋙ " => Iso.trans -- type as `\ll \ggg`.

@[simp]
theorem trans_mk (hom : X ⥤ Y) (inv : Y ⥤ X) (hom_inv_id) (inv_hom_id)
    (hom' : Y ⥤ Z) (inv' : Z ⥤ Y) (hom_inv_id') (inv_hom_id') (hom_inv_id'') (inv_hom_id'') :
    Iso.trans ⟨hom, inv, hom_inv_id, inv_hom_id⟩ ⟨hom', inv', hom_inv_id', inv_hom_id'⟩ =
     ⟨hom ⋙ hom', inv' ⋙ inv, hom_inv_id'', inv_hom_id''⟩ :=
  rfl

@[simp]
theorem trans_symm (α : X ≅≅ Y) (β : Y ≅≅ Z) : (α ≪⋙ β).symm = β.symm ≪⋙ α.symm :=
  rfl

variable {Z' : Type*} [Category Z'] in
@[simp]
theorem trans_assoc (α : X ≅≅ Y) (β : Y ≅≅ Z) (γ : Z ≅≅ Z') :
    (α ≪⋙ β) ≪⋙ γ = α ≪⋙ β ≪⋙ γ := by
  ext; simp only [trans_hom, Functor.assoc]

@[simp]
theorem refl_trans (α : X ≅≅ Y) : Iso.refl X ≪⋙ α = α := by ext; apply Functor.id_comp

@[simp]
theorem trans_refl (α : X ≅≅ Y) : α ≪⋙ Iso.refl Y = α := by ext; apply Functor.comp_id

@[simp]
theorem symm_self_id (α : X ≅≅ Y) : α.symm ≪⋙ α = Iso.refl Y :=
  ext α.inv_hom_id

@[simp]
theorem self_symm_id (α : X ≅≅ Y) : α ≪⋙ α.symm = Iso.refl X :=
  ext α.hom_inv_id

@[simp]
theorem symm_self_id_assoc (α : X ≅≅ Y) (β : Y ≅≅ Z) : α.symm ≪⋙ α ≪⋙ β = β := by
  rw [← trans_assoc, symm_self_id, refl_trans]

@[simp]
theorem self_symm_id_assoc (α : X ≅≅ Y) (β : X ≅≅ Z) : α ≪⋙ α.symm ≪⋙ β = β := by
  rw [← trans_assoc, self_symm_id, refl_trans]

theorem inv_comp_eq (α : X ≅≅ Y) {f : X ⥤ Z} {g : Y ⥤ Z} : α.inv ⋙ f = g ↔ f = α.hom ⋙ g :=
  ⟨fun H => by simp [H.symm, ← Functor.assoc, Functor.id_comp],
   fun H => by simp [H, ← Functor.assoc, Functor.id_comp]⟩

theorem eq_inv_comp (α : X ≅≅ Y) {f : X ⥤ Z} {g : Y ⥤ Z} : g = α.inv ⋙ f ↔ α.hom ⋙ g = f :=
  (inv_comp_eq α.symm).symm

theorem comp_inv_eq (α : X ≅≅ Y) {f : Z ⥤ Y} {g : Z ⥤ X} : f ⋙ α.inv = g ↔ f = g ⋙ α.hom :=
  ⟨fun H => by simp [H.symm, Functor.assoc, Functor.comp_id],
   fun H => by simp [H, Functor.assoc, Functor.comp_id]⟩

theorem eq_comp_inv (α : X ≅≅ Y) {f : Z ⥤ Y} {g : Z ⥤ X} : g = f ⋙ α.inv ↔ g ⋙ α.hom = f :=
  (comp_inv_eq α.symm).symm

theorem inv_eq_inv (f g : X ≅≅ Y) : f.inv = g.inv ↔ f.hom = g.hom :=
  ⟨fun h => sorry, fun h => by rw [ext h]⟩

theorem hom_comp_eq_id (α : X ≅≅ Y) {f : Y ⥤ X} : α.hom ⋙ f = Functor.id X ↔ f = α.inv := by
  rw [← eq_inv_comp, Functor.comp_id]

theorem comp_hom_eq_id (α : X ≅≅ Y) {f : Y ⥤ X} : f ⋙ α.hom = Functor.id Y ↔ f = α.inv := by
  rw [← eq_comp_inv, Functor.id_comp]

theorem inv_comp_eq_id (α : X ≅≅ Y) {f : X ⥤ Y} : α.inv ⋙ f = Functor.id Y ↔ f = α.hom :=
  hom_comp_eq_id α.symm

theorem comp_inv_eq_id (α : X ≅≅ Y) {f : X ⥤ Y} : f ⋙ α.inv = Functor.id X ↔ f = α.hom :=
  comp_hom_eq_id α.symm

theorem hom_eq_inv (α : X ≅≅ Y) (β : Y ≅≅ X) : α.hom = β.inv ↔ β.hom = α.inv := by
  rw [← symm_inv, inv_eq_inv α.symm β, eq_comm]
  rfl

/-- The bijection `(Z ⥤ X) ≃ (Z ⥤ Y)` induced by `α : X ≅≅ Y`. -/
@[simps]
def homToEquiv (α : X ≅≅ Y) : (Z ⥤ X) ≃ (Z ⥤ Y) where
  toFun f := f ⋙ α.hom
  invFun g := g ⋙ α.inv
  left_inv := sorry
  right_inv := sorry

/-- The bijection `(X ⥤ Z) ≃ (Y ⥤ Z)` induced by `α : X ≅≅ Y`. -/
@[simps]
def homFromEquiv (α : X ≅≅ Y) : (X ⥤ Z) ≃ (Y ⥤ Z) where
  toFun f := α.inv ⋙ f
  invFun g := α.hom ⋙ g
  left_inv := sorry
  right_inv := sorry

@[aesop apply safe (rule_sets := [CategoryTheory])]
theorem inv_ext {f : X ≅≅ Y} {g : Y ⥤ X} (hom_inv_id : f.hom ⋙ g = Functor.id X) : f.inv = g :=
  ((hom_comp_eq_id f).1 hom_inv_id).symm

@[aesop apply safe (rule_sets := [CategoryTheory])]
theorem inv_ext' {f : X ≅≅ Y} {g : Y ⥤ X} (hom_inv_id : f.hom ⋙ g = Functor.id X) : g = f.inv :=
  (hom_comp_eq_id f).1 hom_inv_id

@[simp]
theorem cancel_iso_hom_left (f : X ≅≅ Y) (g g' : Y ⥤ Z) :
    f.hom ⋙ g = f.hom ⋙ g' ↔ g = g' := by
  sorry

@[simp]
theorem cancel_iso_inv_left (f : Y ≅≅ X) (g g' : Y ⥤ Z) :
    f.inv ⋙ g = f.inv ⋙ g' ↔ g = g' := by
  sorry

@[simp]
theorem cancel_iso_hom_right (f f' : X ⥤ Y) (g : Y ≅≅ Z) :
    f ⋙ g.hom = f' ⋙ g.hom ↔ f = f' := by
  sorry

@[simp]
theorem cancel_iso_inv_right (f f' : X ⥤ Y) (g : Z ≅≅ Y) :
    f ⋙ g.inv = f' ⋙ g.inv ↔ f = f' := by
  sorry

variable {W X' : Type*} [Category W] [Category X']
/-
Unfortunately cancelling an isomorphism from the right of a chain of compositions is awkward.
We would need separate lemmas for each chain length (worse: for each pair of chain lengths).

We provide two more lemmas, for case of three morphisms, because this actually comes up in practice,
but then stop.
-/
@[simp]
theorem cancel_iso_hom_right_assoc (f : W ⥤ X) (g : X ⥤ Y) (f' : W ⥤ X')
    (g' : X' ⥤ Y) (h : Y ≅≅ Z) : f ⋙ g ⋙ h.hom = f' ⋙ g' ⋙ h.hom ↔ f ⋙ g = f' ⋙ g' := by
  sorry

@[simp]
theorem cancel_iso_inv_right_assoc (f : W ⥤ X) (g : X ⥤ Y) (f' : W ⥤ X')
    (g' : X' ⥤ Y) (h : Z ≅≅ Y) : f ⋙ g ⋙ h.inv = f' ⋙ g' ⋙ h.inv ↔ f ⋙ g = f' ⋙ g' := by
  sorry

end Iso

end CategoryTheory.Functor

namespace CategoryTheory.AsSmall

variable {C : Type*} [Category C]

def downIso : AsSmall C ≅≅ C where
  hom := AsSmall.down
  inv := AsSmall.up

end CategoryTheory.AsSmall
