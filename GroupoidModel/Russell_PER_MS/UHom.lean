import GroupoidModel.Russell_PER_MS.NaturalModelBase

/-! Morphisms of natural models, and Russell-universe embeddings. -/

universe v u

noncomputable section

open CategoryTheory Limits Opposite

namespace NaturalModelBase

variable {Ctx : Type u} [Category.{v, u} Ctx]

structure Hom (M N : NaturalModelBase Ctx) where
  mapTm : M.Tm ⟶ N.Tm
  mapTy : M.Ty ⟶ N.Ty
  pb : IsPullback mapTm M.tp N.tp mapTy

def Hom.id (M : NaturalModelBase Ctx) : Hom M M where
  mapTm := 𝟙 _
  mapTy := 𝟙 _
  pb := IsPullback.of_id_fst

def Hom.comp {M N O : NaturalModelBase Ctx} (α : Hom M N) (β : Hom N O) : Hom M O where
  mapTm := α.mapTm ≫ β.mapTm
  mapTy := α.mapTy ≫ β.mapTy
  pb := α.pb.paste_horiz β.pb

def Hom.comp_assoc {M N O P : NaturalModelBase Ctx} (α : Hom M N) (β : Hom N O) (γ : Hom O P) :
    comp (comp α β) γ = comp α (comp β γ) := by
  simp [comp]

/-- Morphism into the representable natural transformation `M`
from the pullback of `M` along a type. -/
protected def pullbackHom (M : NaturalModelBase Ctx) {Γ : Ctx} (A : y(Γ) ⟶ M.Ty) :
    Hom (M.pullback A) M where
  mapTm := M.var A
  mapTy := A
  pb := M.disp_pullback A

/-- A Russell embedding is a hom of natural models `M ⟶ N`
such that types in `M` correspond to terms of a universe `U` in `N`.

These don't form a category since `UHom.id M` is essentially `Type : Type` in `M`. -/
structure UHom (M N : NaturalModelBase Ctx) extends Hom M N where
  U : ⊤_ (Psh Ctx) ⟶ N.Ty
  U_pb : ∃ v, IsPullback v (terminal.from M.Ty) N.tp U

  -- Or an explicit bijection:
  -- U_equiv : (y(⊤_ Ctx) ⟶ M.Ty) ≃ { A : y(⊤_ Ctx) ⟶ N.Tm // A ≫ N.tp = U }

def UHom.comp {M N O : NaturalModelBase Ctx} (α : UHom M N) (β : UHom N O) : UHom M O := {
  Hom.comp α.toHom β.toHom with
  U := α.U ≫ β.mapTy
  U_pb :=
    have ⟨v, pb⟩ := α.U_pb
    ⟨v ≫ β.mapTm, pb.paste_horiz β.pb⟩
}

def UHom.comp_assoc {M N O P : NaturalModelBase Ctx} (α : UHom M N) (β : UHom N O) (γ : UHom O P) :
    comp (comp α β) γ = comp α (comp β γ) := by
  simp [comp, Hom.comp]

/- Sanity check:
construct a `UHom` into a natural model with a Tarski universe. -/
def UHom.ofTarskiU [HasTerminal Ctx] (M : NaturalModelBase Ctx)
    (U : y(⊤_ Ctx) ⟶ M.Ty) (El : y(M.ext U) ⟶ M.Ty) :
    UHom (M.pullback El) M := {
  M.pullbackHom El with
  U := (PreservesTerminal.iso (yoneda (C := Ctx))).inv ≫ U
  U_pb := ⟨M.var U,
    (M.disp_pullback U).of_iso
      (Iso.refl _)
      (Iso.refl _)
      (PreservesTerminal.iso (yoneda (C := Ctx)))
      (Iso.refl _)
      (by simp) (terminal.hom_ext ..)
      (by simp) (by rw [Iso.hom_inv_id_assoc]; simp)⟩
}

/-- A sequence of Russell embeddings. -/
structure UHomSeq (Ctx : Type u) [Category.{v, u} Ctx] where
  /-- Number of embeddings in the sequence,
  or one less than the number of models in the sequence. -/
  length : Nat
  objs (i : Nat) (h : i < length + 1) : NaturalModelBase Ctx
  homs' (i : Nat) (h : i < length) : UHom (objs i <| by omega) (objs (i + 1) <| by omega)

namespace UHomSeq

instance : GetElem (UHomSeq Ctx) Nat (NaturalModelBase Ctx) (fun s i => i < s.length + 1) where
  getElem s i h := s.objs i h

def homs (s : UHomSeq Ctx) (i : Nat) (h : i < s.length := by get_elem_tactic) : UHom s[i] s[i+1] :=
  s.homs' i h

/-- Composition of embeddings between `i` and `j` in the chain. -/
def hom (s : UHomSeq Ctx) (i j : Nat) (ij : i < j := by omega)
    (jlen : j < s.length + 1 := by get_elem_tactic) : UHom s[i] s[j] :=
  if h : i + 1 = j then
    h ▸ s.homs i
  else
    (s.homs i).comp <| s.hom (i+1) j
termination_by s.length - i

theorem hom_comp_trans (s : UHomSeq Ctx) (i j k : Nat) (ij : i < j) (jk : j < k)
    (klen : k < s.length + 1) :
    (s.hom i j ij).comp (s.hom j k jk) = s.hom i k (ij.trans jk) := by
  conv_rhs => unfold hom
  conv in s.hom i j _ => unfold hom
  split_ifs
  all_goals try omega
  . rename_i h _
    cases h
    simp
  . rw [UHom.comp_assoc, hom_comp_trans]
termination_by s.length - i

end UHomSeq

/-- The data of Π and λ term formers for every `i, j ≤ length + 1`, interpreting
```
Γ ⊢ᵢ A type  Γ.A ⊢ⱼ B type
--------------------------
Γ ⊢ₘₐₓ₍ᵢ,ⱼ₎ ΠA. B type
```
and
```
Γ ⊢ᵢ A type  Γ.A ⊢ⱼ t : B
-------------------------
Γ ⊢ₘₐₓ₍ᵢ,ⱼ₎ λA. t : ΠA. B
```

This amounts to `O(length²)` data.
One might object that the same formation rules could be modeled with `O(length)` data:
etc etc

However, with `O(length²)` data we can use Lean's own type formers directly,
rather than using `Π (ULift A) (ULift B)`.
The interpretations of types are thus more direct. -/
structure UHomSeqPis (Ctx : Type u) [SmallCategory.{u} Ctx] extends UHomSeq Ctx where
  Pis' (i j : Nat) (ij : i ≤ j) (jlen : j < length + 1) :
    toUHomSeq[i].Ptp.obj toUHomSeq[j].Ty ⟶ toUHomSeq[max i j].Ty
  lams' (i j : Nat) (ij : i ≤ j) (jlen : j < length + 1) :
    toUHomSeq[i].Ptp.obj toUHomSeq[j].Tm  ⟶ toUHomSeq[max i j].Tm
  Pi_pullbacks' (i j : Nat) (ij : i ≤ j) (jlen : j < length + 1) :
    IsPullback (lams' i j ij jlen) (toUHomSeq[i].Ptp.map toUHomSeq[j].tp)
               toUHomSeq[max i j].tp (Pis' i j ij jlen)

namespace UHomSeqPis

variable {Ctx : Type u} [SmallCategory.{u} Ctx]

instance : GetElem (UHomSeqPis Ctx) Nat (NaturalModelBase Ctx) (fun s i => i < s.length + 1) where
  getElem s i h := s.objs i h

variable (s : UHomSeqPis Ctx)

def Pis (i j : Nat) (ij : i ≤ j := by omega) (jlen : j < s.length + 1 := by get_elem_tactic) :
    s[i].Ptp.obj s[j].Ty ⟶ s[max i j].Ty :=
  s.Pis' i j ij jlen

def lams (i j : Nat) (ij : i ≤ j := by omega) (jlen : j < s.length + 1 := by get_elem_tactic) :
    s[i].Ptp.obj s[j].Tm ⟶ s[max i j].Tm :=
  s.lams' i j ij jlen

def Pi_pullbacks (i j : Nat) (ij : i ≤ j := by omega) (jlen : j < s.length + 1 := by get_elem_tactic) :
    IsPullback (s.lams i j) (s[i].Ptp.map s[j].tp) s[max i j].tp (s.Pis i j) :=
  s.Pi_pullbacks' i j ij jlen

-- Sadly, we have to spell out `ij` and `jlen` due to
-- https://leanprover.zulipchat.com/#narrow/stream/270676-lean4/topic/Optional.20implicit.20argument
variable {i j : Nat} (ij : i ≤ j) (jlen : j < s.length)

/--
```
Γ ⊢ᵢ A  Γ.A ⊢ⱼ B
------------------
Γ ⊢ₘₐₓ₍ᵢ,ⱼ₎ ΠA.B
``` -/
def mkPi {Γ : Ctx} (A : y(Γ) ⟶ s[i].Ty) (B : y(s[i].ext A) ⟶ s[j].Ty) : y(Γ) ⟶ s[max i j].Ty :=
  s[i].Ptp_equiv ⟨A, B⟩ ≫ s.Pis i j

/--
```
Γ ⊢ᵢ A  Γ.A ⊢ⱼ t : B
------------------------
Γ ⊢ₘₐₓ₍ᵢ,ⱼ₎ λA. t : ΠA.B
``` -/
def mkLam {Γ : Ctx} (A : y(Γ) ⟶ s[i].Ty) (t : y(s[i].ext A) ⟶ s[j].Tm) : y(Γ) ⟶ s[max i j].Tm :=
  s[i].Ptp_equiv ⟨A, t⟩ ≫ s.lams i j

@[simp]
theorem mkLam_tp {Γ : Ctx} (A : y(Γ) ⟶ s[i].Ty) (B : y(s[i].ext A) ⟶ s[j].Ty)
    (t : y(s[i].ext A) ⟶ s[j].Tm) (t_tp : t ≫ s[j].tp = B) :
    s.mkLam ij jlen A t ≫ s[max i j].tp = s.mkPi ij jlen A B := by
  simp [mkLam, mkPi, (s.Pi_pullbacks i j).w, s[i].Ptp_equiv_naturality_assoc, t_tp]

/--
```
Γ ⊢ᵢ A  Γ ⊢ₘₐₓ₍ᵢ,ⱼ₎ f : ΠA. B
-----------------------------
Γ.A ⊢ⱼ f[↑] v₀ : B
``` -/
def elimLam {Γ : Ctx} (A : y(Γ) ⟶ s[i].Ty) (B : y(s[i].ext A) ⟶ s[j].Ty)
    (f : y(Γ) ⟶ s[max i j].Tm) (f_tp : f ≫ s[max i j].tp = s.mkPi ij jlen A B) :
    y(s[i].ext A) ⟶ s[j].Tm := by
  let total : y(Γ) ⟶ s[i].Ptp.obj s[j].Tm :=
    (s.Pi_pullbacks i j).lift f (s[i].Ptp_equiv ⟨A, B⟩) f_tp
  -- bug: `get_elem_tactic` fails on `i` with
  -- convert (s[i].Ptp_equiv.symm total).snd
  let this := s[i].Ptp_equiv.symm total
  convert this.snd
  have eq : total ≫ s[i].Ptp.map s[j].tp = s[i].Ptp_equiv ⟨A, B⟩ :=
    (s.Pi_pullbacks i j).isLimit.fac _ (some .right)
  simpa [s[i].Ptp_equiv_symm_naturality] using (s[i].Ptp_ext.mp eq).left.symm

@[simp]
theorem elimLam_tp {Γ : Ctx} (A : y(Γ) ⟶ s[i].Ty) (B : y(s[i].ext A) ⟶ s[j].Ty)
    (f : y(Γ) ⟶ s[max i j].Tm) (f_tp : f ≫ s[max i j].tp = s.mkPi ij jlen A B) :
    s.elimLam ij jlen A B f f_tp ≫ s[j].tp = B := by
  -- This proof is `s[i].Ptp_equiv_symm_naturality`, `IsPullback.lift_snd`, and ITT gunk.
  dsimp only [elimLam]
  generalize_proofs _ _ _ pf pf'
  have := pf.lift_snd f (s[i].Ptp_equiv ⟨A, B⟩) f_tp
  generalize pf.lift f (s[i].Ptp_equiv ⟨A, B⟩) f_tp = x at this pf'
  have := congrArg s[i].Ptp_equiv.symm this
  simp only [s[i].Ptp_equiv_symm_naturality, Equiv.symm_apply_apply, Sigma.mk.inj_iff] at this
  cases this.left
  simp [← eq_of_heq this.right]

/--
```
Γ ⊢ₘₐₓ₍ᵢ,ⱼ₎ f : ΠA. B  Γ ⊢ᵢ a : A
---------------------------------
Γ ⊢ⱼ f a : B[id.a]
``` -/
def mkApp {Γ : Ctx} (A : y(Γ) ⟶ s[i].Ty) (B : y(s[i].ext A) ⟶ s[j].Ty)
    (f : y(Γ) ⟶ s[max i j].Tm) (f_tp : f ≫ s[max i j].tp = s.mkPi ij jlen A B)
    (a : y(Γ) ⟶ s[i].Tm) (a_tp : a ≫ s[i].tp = A) : y(Γ) ⟶ s[j].Tm :=
  s[i].inst A (s.elimLam ij jlen A B f f_tp) a a_tp

@[simp]
theorem mkApp_tp {Γ : Ctx} (A : y(Γ) ⟶ s[i].Ty) (B : y(s[i].ext A) ⟶ s[j].Ty)
    (f : y(Γ) ⟶ s[max i j].Tm) (f_tp : f ≫ s[max i j].tp = s.mkPi ij jlen A B)
    (a : y(Γ) ⟶ s[i].Tm) (a_tp : a ≫ s[i].tp = A) :
    s.mkApp ij jlen A B f f_tp a a_tp ≫ s[j].tp = s[i].inst A B a a_tp := by
  simp [mkApp]

/--
```
Γ ⊢ₘₐₓ₍ᵢ,ⱼ₎ f : ΠA. B
--------------------------------------
Γ ⊢ₘₐₓ₍ᵢ,ⱼ₎ (λA. f[↑] v₀) ≡ f : ΠA. B
``` -/
@[simp]
theorem mkLam_elimLam {Γ : Ctx} (A : y(Γ) ⟶ s[i].Ty) (B : y(s[i].ext A) ⟶ s[j].Ty)
    (f : y(Γ) ⟶ s[max i j].Tm) (f_tp : f ≫ s[max i j].tp = s.mkPi ij jlen A B)
    (a : y(Γ) ⟶ s[i].Tm) (a_tp : a ≫ s[i].tp = A) :
    -- TODO: is `elimLam` what `λA. f[↑] v₀` actually interprets to?
    s.mkLam ij jlen A (s.elimLam ij jlen A B f f_tp) = f := by
  sorry

@[simp]
theorem elimLam_mkLam {Γ : Ctx} (A : y(Γ) ⟶ s[i].Ty) (B : y(s[i].ext A) ⟶ s[j].Ty)
    (t : y(s[i].ext A) ⟶ s[j].Tm) (t_tp : t ≫ s[j].tp = B)
    (lam_tp : s.mkLam ij jlen A t ≫ s[max i j].tp = s.mkPi ij jlen A B) :
    s.elimLam ij jlen A B (s.mkLam ij jlen A t) lam_tp = t := by
  sorry

/--
```
Γ ⊢ᵢ A  Γ.A ⊢ⱼ t : B  Γ ⊢ᵢ a : A
--------------------------------
Γ.A ⊢ⱼ (λA. t) a ≡ t[a] : B[a]
``` -/
@[simp]
theorem mkApp_mkLam {Γ : Ctx} (A : y(Γ) ⟶ s[i].Ty) (B : y(s[i].ext A) ⟶ s[j].Ty)
    (t : y(s[i].ext A) ⟶ s[j].Tm) (t_tp : t ≫ s[j].tp = B)
    (lam_tp : s.mkLam ij jlen A t ≫ s[max i j].tp = s.mkPi ij jlen A B)
    (a : y(Γ) ⟶ s[i].Tm) (a_tp : a ≫ s[i].tp = A) :
    -- Q: should `inst ..` be the simp-NF, or should the more basic `_ ≫ σ`?
    s.mkApp ij jlen A B (s.mkLam ij jlen A t) lam_tp a a_tp = s[i].inst A t a a_tp := by
  rw [mkApp, elimLam_mkLam]
  assumption

end UHomSeqPis
