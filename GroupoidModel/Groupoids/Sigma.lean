import GroupoidModel.Groupoids.NaturalModelBase
import GroupoidModel.Russell_PER_MS.NaturalModelSigma
import SEq.Tactic.DepRewrite

universe v u v₁ u₁ v₂ u₂ v₃ u₃

noncomputable section
-- NOTE temporary section for stuff to be moved elsewhere
section ForOther
open CategoryTheory NaturalModelBase Opposite Grothendieck.Groupoidal

namespace CategoryTheory

namespace Grpd

@[simp] theorem id_obj {C : Grpd} (X : C) :
    (𝟙 C : C ⥤ C).obj X = X :=
  rfl

@[simp] theorem comp_obj {C D E : Grpd} (F : C ⟶ D) (G : D ⟶ E)
    (X : C) : (F ≫ G).obj X = G.obj (F.obj X) :=
  rfl

variable {Γ : Type u} [Category.{v} Γ] (F : Γ ⥤ Grpd.{v₁,u₁})

@[simp] theorem map_eqToHom_obj {x y : Γ} (h : x = y) (t) :
    (F.map (eqToHom h)).obj t = cast (by rw [h]) t := by
  subst h
  simp

-- set_option pp.proofs true
@[simp] theorem map_eqToHom_map {x y : Γ} (h : x = y) {t s} (f : t ⟶ s) :
    (F.map (eqToHom h)).map f =
    eqToHom (Functor.congr_obj (eqToHom_map _ _) t)
    ≫ cast (Grpd.eqToHom_hom_aux t s (by rw [h])) f
    ≫ eqToHom (Eq.symm (Functor.congr_obj (eqToHom_map _ _) s)) := by
  have h1 : F.map (eqToHom h) = eqToHom (by rw [h]) := eqToHom_map _ _
  rw [Functor.congr_hom h1, Grpd.eqToHom_hom]

end Grpd

namespace Grothendieck

namespace Groupoidal

variable {C : Type u} [Category.{v, u} C] {F : C ⥤ Grpd} {X Y : C}

@[simp] lemma sec_map_base {α : C ⥤ PGrpd.{v₁,u₁}} {x y} {f : x ⟶ y} :
    ((Grothendieck.Groupoidal.sec α).map f).base = f := by
  simp [Grothendieck.Groupoidal.sec, Grothendieck.Groupoidal.sec',
            IsMegaPullback.lift, Grothendieck.IsMegaPullback.lift]

@[simp] lemma sec_map_fiber {α : C ⥤ PGrpd.{v₁,u₁}} {x y} {f : x ⟶ y} :
    ((Grothendieck.Groupoidal.sec α).map f).fiber = (α.map f).point := by
  simp [Grothendieck.Groupoidal.sec, Grothendieck.Groupoidal.sec',
            IsMegaPullback.lift, Grothendieck.IsMegaPullback.lift,
            Grothendieck.IsMegaPullback.lift_map,
            Grothendieck.IsMegaPullback.point]

@[simp] theorem ιNatTrans_app_base
    (f : X ⟶ Y) (d : ↑(F.obj X)) : ((ιNatTrans f).app d).base = f :=
  Grothendieck.ιNatTrans_app_base _ _

@[simp] theorem ιNatTrans_app_fiber (f : X ⟶ Y) (d : F.obj X) :
    ((ιNatTrans f).app d).fiber
    = 𝟙 ((F.map f).obj ((Groupoidal.ι F X).obj d).fiber) :=
  Grothendieck.ιNatTrans_app_fiber _ _

end Groupoidal

end Grothendieck

end CategoryTheory

end ForOther

-- NOTE content for this doc starts here
namespace GroupoidModel

open CategoryTheory NaturalModelBase Opposite Grothendieck.Groupoidal

notation:max "@(" Γ ")" => Ctx.toGrpd.obj Γ

namespace FunctorOperation

section
variable {Γ : Type u₂} [Category.{v₂} Γ] {A : Γ ⥤ Grpd.{v₁,u₁}}
    (B : ∫(A) ⥤ Grpd.{v₁,u₁}) (x : Γ)
/--
For a point `x : Γ`, `(sigma A B).obj x` is the groupoidal Grothendieck
  construction on the composition
  `ι _ x ⋙ B : A.obj x ⥤ Groupoidal A ⥤ Grpd`
-/
@[simp, reducible] def sigmaObj := ∫(ι A x ⋙ B)

variable {x} {y : Γ} (f : x ⟶ y)
/--
For a morphism `f : x ⟶ y` in `Γ`, `(sigma A B).map y` is a
composition of functors.
The first functor `map (whiskerRight (ιNatTrans f) B)`
is an equivalence which replaces `ι A x` with the naturally
isomorphic `A.map f ⋙ ι A y`.
The second functor is the action of precomposing
`A.map f` with `ι A y ⋙ B` on the Grothendieck constructions.

            map ⋯                  pre ⋯
  ∫ ι A x ⋙ B ⥤ ∫ A.map f ⋙ ι A y ⋙ B ⥤ ∫ ι A y ⋙ B
-/
def sigmaMap : sigmaObj B x ⥤ sigmaObj B y :=
  map (whiskerRight (ιNatTrans f) B) ⋙ pre (ι A y ⋙ B) (A.map f)

variable {B}

@[simp] theorem sigmaMap_id_obj {p} : (sigmaMap B (𝟙 x)).obj p = p := by
  simp only [sigmaMap, Functor.comp_obj, map_obj, Functor.id_obj]
  apply obj_ext_hEq
  · rw [pre_obj_base, Grpd.map_id_obj]
  · simp

@[simp] theorem sigmaMap_id_map {p1 p2} (f : p1 ⟶ p2) :
    (sigmaMap B (𝟙 x)).map f =
    eqToHom (by simp) ≫ f ≫ eqToHom (by simp) := by
  let t := @ιNatTrans _ _ A _ _ (CategoryStruct.id x)
  have h (a : A.obj x) : B.map (t.app a) =
      eqToHom (by simp [Functor.map_id]) :=
    calc
      B.map (t.app a)
      _ = B.map (eqToHom (by simp [Functor.map_id])) := by
        rw [ιNatTrans_id_app]
      _ = eqToHom (by simp [Functor.map_id]) := by
        simp [eqToHom_map]
  dsimp only [sigmaMap]
  simp only [Functor.comp_map, Functor.id_map]
  apply Grothendieck.Groupoidal.ext
  · simp only [pre_map_fiber, map_map_fiber, whiskerRight_app, eqToHom_trans_assoc, comp_fiber, eqToHom_fiber, eqToHom_map]
    -- NOTE rw! much faster here for map_eqToHom_map and Functor.congr_hom
    rw! [Functor.congr_hom (h p2.base) f.fiber, eqToHom_base,
      Grpd.map_eqToHom_map, Grpd.eqToHom_hom]
    -- NOTE ι_obj, ι_map really unhelpful when there is an eqToHom
    simp only [Category.assoc, eqToHom_trans, eqToHom_trans_assoc]
  · simp

theorem sigmaMap_id : sigmaMap B (CategoryStruct.id x) = Functor.id _ := by
    apply CategoryTheory.Functor.ext
    · intro p1 p2 f
      simp
    · intro p
      simp

variable {z : Γ} {f} {g : y ⟶ z}

@[simp] theorem sigmaMap_comp_obj {p} : (sigmaMap B (f ≫ g)).obj p =
    (sigmaMap B g).obj ((sigmaMap B f).obj p) := by
  dsimp only [sigmaMap]
  apply obj_ext_hEq
  · simp
  · simp

@[simp] theorem sigmaMap_comp_map {A : Γ ⥤ Grpd.{v₁,u₁}}
    {B : ∫(A) ⥤ Grpd.{v₁,u₁}} {x y z : Γ} {f : x ⟶ y} {g : y ⟶ z}
    {p q} (hpq : p ⟶ q) {h1} {h2} :
    (sigmaMap B (f ≫ g)).map hpq =
    eqToHom h1 ≫ (sigmaMap B g).map ((sigmaMap B f).map hpq) ≫ eqToHom h2 := by
  -- let t := B.map ((ιNatTrans (f ≫ g)).app q.base)
  have h : B.map ((ιNatTrans (f ≫ g)).app q.base) =
    B.map ((ιNatTrans f).app q.base)
    ≫ B.map ((ιNatTrans g).app ((A.map f).obj q.base))
    ≫ eqToHom (by simp) := by simp [eqToHom_map]
  dsimp only [sigmaMap]
  apply Grothendieck.Groupoidal.ext
  · have h3 : (ι A z ⋙ B).map (eqToHom h2).base
        = eqToHom (by simp [sigmaMap]) := by
      rw [eqToHom_base, eqToHom_map]
    conv =>
      right
      simp only [comp_fiber, eqToHom_fiber, eqToHom_map]
      rw! [Functor.congr_hom h3]
    conv =>
      left
      -- NOTE with rw this will timeout
      rw! [map_map_fiber]
      -- simp only [eqToHom_trans_assoc]
      simp only [Functor.comp_obj, map_obj, whiskerRight_app, Functor.comp_map,
        pre_map_base, map_map_base]
      -- NOTE not sure what some of these simp lemmas are doing,
      -- but when present, rw! [h] works
      -- NOTE with rw this will timeout
      rw! [Functor.congr_hom h]
      simp only [Grpd.comp_eq_comp, Functor.comp_map, Grpd.eqToHom_hom]
    apply eq_of_heq
    simp only [Functor.comp_map, eqToHom_trans_assoc, pre_map_fiber,
      map_map_fiber, Functor.map_comp, eqToHom_map, Grpd.eqToHom_hom,
      Category.assoc, eqToHom_trans, heq_eqToHom_comp_iff,
      eqToHom_comp_heq_iff, comp_eqToHom_heq_iff,
      heq_comp_eqToHom_iff, cast_heq_iff_heq]
    simp only [Functor.comp_obj, id_eq, pre_obj_base, Grpd.comp_eq_comp,
      map_obj, whiskerRight_app, Functor.comp_map, heq_cast_iff_heq,
      heq_eqToHom_comp_iff, heq_eq_eq]
  · simp

theorem sigmaMap_comp :
    sigmaMap B (f ≫ g) = sigmaMap B f ⋙ sigmaMap B g := by
  apply CategoryTheory.Functor.ext
  · intro p q hpq
    simp
  · intro p
    simp

/-- The formation rule for Σ-types for the ambient natural model `base`
  unfolded into operations between functors.
  See `sigmaObj` and `sigmaMap` for the actions of this functor.
 -/
@[simps] def sigma (A : Γ ⥤ Grpd.{v₁,u₁})
    (B : ∫(A) ⥤ Grpd.{v₁,u₁}) : Γ ⥤ Grpd.{v₁,u₁} where
  -- NOTE using Grpd.of here instead of earlier speeds things up
  obj x := Grpd.of $ sigmaObj B x
  map := sigmaMap B
  map_id _ := sigmaMap_id
  map_comp _ _ := sigmaMap_comp

variable {Δ : Type u₃} [Category.{v₃} Δ] (σ : Δ ⥤ Γ)

theorem sigmaBeckChevalley : σ ⋙ sigma A B = sigma (σ ⋙ A) (pre A σ ⋙ B) := by
  refine CategoryTheory.Functor.ext ?_ ?_
  . intros x
    dsimp only [Functor.comp_obj, sigma_obj, sigmaObj]
    rw! [← ιCompPre σ A x]
    rfl
  . intros x y f
    sorry -- this goal might be improved by adding API for Groupoidal.ι and Groupoidal.pre

end

section

variable {Γ : Type u₂} [Category.{v₂} Γ] {α β : Γ ⥤ PGrpd.{v₁,u₁}}
  {B : ∫(α ⋙ PGrpd.forgetToGrpd) ⥤ Grpd.{v₁,u₁}}
  (h : β ⋙ PGrpd.forgetToGrpd = sec α ⋙ B)

def pairSectionObj (x : Γ) :
    ∫(sigma (α ⋙ PGrpd.forgetToGrpd) B) :=
  ⟨ x, (α.obj x).str.pt, PGrpd.compForgetToGrpdObjPt h x ⟩

def pairSectionMap {x y} (f : x ⟶ y) :
    pairSectionObj h x ⟶ pairSectionObj h y :=
    have := by
      -- NOTE Not sure how we can make this goal more readable
      simp only [Functor.comp_obj, Grpd.forgetToCat.eq_1,
        sigma_obj, sigmaObj, Functor.comp_map, sigma_map, sigmaMap,
        PGrpd.forgetToGrpd_map, id_eq, map_obj,
        whiskerRight_app, pre_obj_base, pre_obj_fiber]
      rw [← Grpd.map_comp_obj]
      congr 3
      apply Grothendieck.Groupoidal.ext
      · simp [ι_map]
      · simp [ι_map]
    ⟨ f, (α.map f).point, eqToHom this ≫ PGrpd.compForgetToGrpdMapPoint h f ⟩

@[simp] theorem pairSection_map_id_base (x) :
    (pairSectionMap h (CategoryStruct.id x)).base = CategoryStruct.id x := by
  simp [pairSectionMap]

-- NOTE these simp lemmas from mathlib should maybe be removed
-- Grpd.forgetToCat...?

@[simp] theorem pairSection_map_id_fiber (x) :
    (pairSectionMap h (CategoryStruct.id x)).fiber
    = eqToHom (by simp [pairSectionObj]):= by
  apply Grothendieck.Groupoidal.ext
  · simp [pairSectionMap]
  · simp [pairSectionMap]

theorem pairSection_map_id (x) :
    pairSectionMap h (CategoryStruct.id x) = CategoryStruct.id _ := by
  apply Grothendieck.ext
  · simp
  · rfl

theorem pairSection_map_comp {x y z} (f : x ⟶ y) (g : y ⟶ z) :
    pairSectionMap _ (f ≫ g) = pairSectionMap h f ≫ pairSectionMap h g := by
  apply Grothendieck.ext
  · simp [pairSectionMap]
    sorry
  · simp [pairSectionMap]

def pairSection : Γ ⥤ ∫(sigma (α ⋙ PGrpd.forgetToGrpd) B) where
    obj := pairSectionObj h
    map {x y} := pairSectionMap h
    map_id := pairSection_map_id _
    map_comp f g := by
      convert_to pairSectionMap _ (f ≫ g) = pairSectionMap _ f ≫ pairSectionMap _ g
      sorry
      -- fapply Grothendieck.ext
      -- . rfl
      -- . dsimp
      --   simp only [Category.id_comp]
      --   · apply Grothendieck.ext
          -- . -- simp only [ι, Grpd.forgetToCat, Functor.comp_obj, Grothendieck.ι_obj, Cat.of_α, Grpd.coe_of, id_eq,
            --   Grothendieck.ιNatTrans, PGrpd.forgetToGrpd_obj, Functor.comp_map,
            --   PGrpd.forgetToGrpd_map, map, whiskerRight_twice,
            --   Grothendieck.Groupoidal.pre, Grothendieck.pre_obj_base, Grothendieck.map_obj_base, Grothendieck.ι_map,
            --   Grothendieck.pre_obj_fiber, Grothendieck.map_obj_fiber, whiskerRight_app, Grpd.forgetToGrpdMapPoint,
            --   Grothendieck.comp_base, Grothendieck.pre_map_base, Grothendieck.map_map_base, eqToHom_trans_assoc,
            --   Grothendieck.comp_fiber, Grothendieck.fiber_eqToHom, eqToHom_map, Grothendieck.pre_map_fiber,
            --   Grothendieck.map_map_fiber, Functor.map_comp, Category.assoc]
            -- have h3 : β.map (f ≫ g) = _ := Functor.map_comp _ _ _
            -- have h4 : Grpd.homOf (β.map g).toFunctor = _ := Functor.congr_hom h g
            -- simp only [Grpd.homOf] at h4
            -- simp only [PointedFunctor.congr_point h3, PGrpd.comp_toFunctor, Functor.comp_obj, PGrpd.comp_point,
            --   Category.assoc]
            -- rw [Functor.congr_hom h4 (β.map f).point]
            -- simp only [Grpd.comp_eq_comp, Functor.map_comp]
            -- simp only [eqToHom_map]
            -- simp only [Grothendieck.Groupoidal.sec, IsMegaPullback.lift,
            --   Grothendieck.IsMegaPullback.lift, Grothendieck.IsMegaPullback.lift_map]
            -- sorry
          -- . sorry --simp [Grpd.forgetToCat, Grothendieck.Groupoidal.pre, map, PGrpd.map_comp_point]

theorem pairSection_comp_forget :
    (pairSection h) ⋙ Grothendieck.forget _ = Functor.id Γ :=
  rfl

def pair : Γ ⥤ PGrpd.{v₁,u₁} := pairSection h ⋙ toPGrpd _

theorem pair_comp_forget :
    pair h ⋙ PGrpd.forgetToGrpd = sigma (α ⋙ PGrpd.forgetToGrpd) B := by
  unfold pair
  rw [Functor.assoc]
  exact rfl

end

variable {Γ : Type u₂} [Category.{v₂} Γ] {A : Γ ⥤ Grpd.{v₁,u₁}}
    (B : ∫(A) ⥤ Grpd.{v₁,u₁}) (x : Γ)

def fstAux : sigma A B ⟶ A where
  app x := Grpd.homOf (Grothendieck.forget _)

def fst : ∫(sigma A B) ⥤ ∫(A) :=
  map (fstAux B)

-- JH: changed name from `snd` to `assoc`
-- maybe we should use `Grothendieck.functorFrom`
def assoc : ∫(sigma A B) ⥤ ∫(B) := sorry

def snd : ∫(sigma A B) ⥤ PGrpd :=
  assoc B ⋙ toPGrpd B

-- set_option maxHeartbeats 0 in
-- def snd {Γ : Grpd} (A : Γ ⥤ Cat.of Grpd.{v₁,u₁})
--     (B : Grothendieck.Groupoidal A ⥤ Grpd.{v₁,u₁}) :
--   Grothendieck.Groupoidal (sigma A B) ⥤  Grothendieck.Groupoidal B where
--   obj x := by
--     rcases x with ⟨base,fiber,fiberfiber⟩
--     fconstructor
--     fconstructor
--     . exact base
--     . exact fiber
--     . exact fiberfiber
--   map {x y} f := by
--     rcases f with ⟨base,fiber,fiberfiber⟩
--     fconstructor
--     fconstructor
--     . exact base
--     . exact fiber
--     . refine eqToHom ?_ ≫ fiberfiber
--       . simp[Grpd.forgetToCat,Grothendieck.Groupoidal.pre,whiskerRight,map]
--         set I := ((ι A y.base).map fiber)
--         set J := (@Grothendieck.ιNatTrans (↑Γ) Groupoid.toCategory (Groupoid.compForgetToCat A) x.base y.base base).app x.fiber.base
--         have eq1 : (B.map I).obj ((B.map J).obj x.fiber.fiber) = (B.map J ≫ B.map I).obj x.fiber.fiber := rfl
--         rw [eq1,<- B.map_comp J I]
--         simp[J,I,CategoryStruct.comp,Grothendieck.comp,ι]
--         refine Functor.congr_obj ?_ x.fiber.fiber
--         refine congrArg B.map ?_
--         apply Grothendieck.ext
--         . simp
--         . simp
--   map_id := by
--     intro x
--     simp[Grothendieck.Hom.rec,Grothendieck.Hom.rec]
--     sorry
--   map_comp := sorry

def ABToAlpha : ∫(sigma A B) ⥤ PGrpd :=
  fst B ⋙ toPGrpd A

def ABToB : ∫(ABToAlpha B ⋙ PGrpd.forgetToGrpd) ⥤ Grpd := by
  refine ?_ ⋙ fst B ⋙ B
  exact Grothendieck.forget (Groupoid.compForgetToCat (ABToAlpha B ⋙ PGrpd.forgetToGrpd))

def ABToBeta : ∫(sigma A B) ⥤ PGrpd :=
  assoc B ⋙ (Grothendieck.Groupoidal.toPGrpd B)

end FunctorOperation

open FunctorOperation

/-- The formation rule for Σ-types for the ambient natural model `base` -/
def baseSig : base.Ptp.obj base.{u}.Ty ⟶ base.Ty where
  app Γ := fun p =>
    let ⟨A,B⟩ := baseUvPolyTpEquiv p
    yonedaEquiv (yonedaCatEquiv.symm (sigma A B))
  naturality := sorry -- do not attempt

def basePair : base.uvPolyTp.compDom base.uvPolyTp ⟶ base.Tm where
  app Γ := fun ε =>
    let ⟨α,B,β,h⟩ := baseUvPolyTpCompDomEquiv ε
    yonedaEquiv (yonedaCatEquiv.symm (pair h))
  naturality := by sorry

def Sigma_Comm : basePair ≫ base.tp = (base.uvPolyTp.comp base.uvPolyTp).p ≫ baseSig := by sorry

def PairUP' {Γ : Ctx.{u}} (AB : yoneda.obj Γ ⟶ base.Ptp.obj base.{u}.Ty) :
    yoneda.obj (base.ext (AB ≫ baseSig)) ⟶ base.uvPolyTp.compDom base.uvPolyTp := by
  -- sorry
  refine yonedaEquiv.invFun ?_
  refine baseUvPolyTpCompDomEquiv.invFun ?_
  let AB' := baseUvPolyTpEquiv (yonedaEquiv.toFun AB)
  exact ⟨ABToAlpha AB'.snd, ABToB AB'.snd, ABToBeta AB'.snd, by
    -- simp
    sorry
  ⟩

-- NOTE this has been refactored through sec'
-- def GammaToSigma {Γ : Ctx} (top : (yoneda.obj Γ) ⟶ base.Tm)
--     (left : (yoneda.obj Γ) ⟶ base.Ptp.obj base.{u}.Ty)
--     (h : top ≫ base.tp = left ≫ baseSig) :
--     (yoneda.obj Γ) ⟶ yoneda.obj (base.ext (left ≫ baseSig)) :=
--   (base.disp_pullback (left ≫ baseSig)).lift top (𝟙 _) (by rw[Category.id_comp,h])

-- def GammaToSigmaInv_disp {Γ : Ctx} (top : (yoneda.obj Γ) ⟶ base.Tm) (left : (yoneda.obj Γ) ⟶ base.Ptp.obj base.{u}.Ty) (h : top ≫ base.tp = left ≫ baseSig) : (base.sec' top _ h) ≫ (yoneda.map (base.disp (left ≫ baseSig))) = 𝟙 (yoneda.obj Γ) := by
--   simp [sec']

def PairUP {Γ : Ctx} (top : (yoneda.obj Γ) ⟶ base.Tm)
    (left : (yoneda.obj Γ) ⟶ base.Ptp.obj base.{u}.Ty)
    (h : top ≫ base.tp = left ≫ baseSig) :
    (yoneda.obj Γ) ⟶ base.uvPolyTp.compDom base.uvPolyTp :=
  base.sec' h ≫ (PairUP' left)

namespace SigmaPullback

def somethingEquiv' {Γ : Ctx} {ab : y(Γ) ⟶ base.Tm}
  (A : (Ctx.toGrpd.obj Γ) ⥤ Grpd.{u,u})
  (B : ∫(A) ⥤ Grpd.{u,u})
  (sigAB : ↑(Ctx.toGrpd.obj Γ) ⥤ Grpd.{u,u})
  (ab : Ctx.toGrpd.obj Γ ⥤ PGrpd.{u,u})
  (h : ab ⋙ PGrpd.forgetToGrpd = sigAB) :
  (α : Ctx.toGrpd.obj Γ ⥤ PGrpd.{u,u}) ×'
  (α ⋙ PGrpd.forgetToGrpd = A) := sorry

theorem yonedaCatEquiv_baseSig {Γ : Ctx} {A : Ctx.toGrpd.obj Γ ⥤ Grpd.{u,u}}
    {B : ∫(A) ⥤ Grpd.{u,u}} :
    yonedaCatEquiv ((baseUvPolyTpEquiv'.symm ⟨A,B⟩) ≫ baseSig) = sigma A B
    := by
  simp only [yonedaCatEquiv, Equiv.trans_apply, yonedaEquiv_comp, baseSig, Equiv.symm_trans_apply, Equiv.toFun_as_coe, baseUvPolyTpEquiv]
  rw [yonedaCatEquivAux.apply_eq_iff_eq_symm_apply,
    yonedaEquiv.apply_eq_iff_eq_symm_apply,
    Equiv.symm_apply_apply, Equiv.apply_symm_apply]
  congr

def somethingEquiv {Γ : Ctx} {ab : y(Γ) ⟶ base.Tm}
    {AB : y(Γ) ⟶ base.Ptp.obj base.{u}.Ty}
    (h : ab ≫ base.tp = AB ≫ baseSig)
    : (A : Ctx.toGrpd.obj Γ ⥤ Grpd.{u,u})
    × (α : Ctx.toGrpd.obj Γ ⥤ PGrpd.{u,u})
    × (B : ∫(A) ⥤ Grpd.{u,u})
    × (β : Ctx.toGrpd.obj Γ ⥤ PGrpd.{u,u})
    ×' (h : α ⋙ PGrpd.forgetToGrpd = A)
    ×' β ⋙ PGrpd.forgetToGrpd = Grothendieck.Groupoidal.sec α ⋙ Grothendieck.Groupoidal.map (eqToHom h) ⋙ B :=
  let AB' := baseUvPolyTpEquiv (yonedaEquiv AB)
  let A := AB'.1
  let B := AB'.2
  let h1 := baseTmEquiv ⟨AB ≫ baseSig,ab,h⟩
  let sigAB := h1.1
  let ab' := h1.2.1
  let hab := h1.2.2
  have h2 : ab' ⋙ PGrpd.forgetToGrpd = sigma AB'.fst B := by
      rw [hab, baseTmEquiv_fst, ← yonedaCatEquiv_baseSig, Sigma.eta]
      simp [AB', baseUvPolyTpEquiv]
  let α := sec ab' ⋙ map (eqToHom h2) ⋙ fst B ⋙ toPGrpd A
  ⟨ A,
    α,
    B,
    sorry,
    sorry,
    sorry ⟩

-- strategy: want to first show that cones of the diagram
-- correspond to some functor data,
-- then do the functor constructions
def lift {Γ : Ctx} {ab : y(Γ) ⟶ base.Tm}
    {AB : y(Γ) ⟶ base.Ptp.obj base.{u}.Ty}
    (h : ab ≫ base.tp = AB ≫ baseSig) :
    (yoneda.obj Γ) ⟶ base.uvPolyTp.compDom base.uvPolyTp :=
  yonedaEquiv.invFun $
  baseUvPolyTpCompDomEquiv'.invFun
  (somethingEquiv h)

end SigmaPullback

theorem PairUP_Comm1' {Γ : Ctx} (top : (yoneda.obj Γ) ⟶ base.Tm) (left : (yoneda.obj Γ) ⟶ base.Ptp.obj base.{u}.Ty) (h : top ≫ base.tp = left ≫ baseSig) : PairUP' left ≫ basePair = (yoneda.map (base.disp (left ≫ baseSig))) ≫ top := by
  sorry

theorem PairUP_Comm1 {Γ : Ctx} (top : (yoneda.obj Γ) ⟶ base.Tm) (left : (yoneda.obj Γ) ⟶ base.Ptp.obj base.{u}.Ty) (h : top ≫ base.tp = left ≫ baseSig) : (PairUP top left h) ≫ basePair = top := by
  unfold PairUP
  rw[Category.assoc,PairUP_Comm1' top left h,<- Category.assoc,
    sec'_disp,Category.id_comp]

theorem PairUP_Comm2' {Γ : Ctx} (top : (yoneda.obj Γ) ⟶ base.Tm) (left : (yoneda.obj Γ) ⟶ base.Ptp.obj base.{u}.Ty) (h : top ≫ base.tp = left ≫ baseSig) : PairUP' left ≫ (base.uvPolyTp.comp base.uvPolyTp).p = (yoneda.map (base.disp (left ≫ baseSig))) ≫ left := by
  sorry

theorem PairUP_Comm2 {Γ : Ctx} (top : (yoneda.obj Γ) ⟶ base.Tm)
    (left : (yoneda.obj Γ) ⟶ base.Ptp.obj base.{u}.Ty)
    (h : top ≫ base.tp = left ≫ baseSig) :
    (PairUP top left h) ≫ (base.uvPolyTp.comp base.uvPolyTp).p = left
    := by
  unfold PairUP
  rw[Category.assoc,PairUP_Comm2' top left h,<- Category.assoc,
    sec'_disp,Category.id_comp]

theorem PairUP_Uniqueness {Γ : Ctx}
    (f : (yoneda.obj Γ) ⟶ base.uvPolyTp.compDom base.uvPolyTp) :
    f = (PairUP (f ≫  basePair)
      (f ≫ (base.uvPolyTp.comp base.uvPolyTp).p)
      (by rw[Category.assoc,Category.assoc]; congr 1; exact Sigma_Comm))     := by
  unfold PairUP
  refine (base.uvPolyTpCompDomEquiv Γ).injective ?_
  refine Sigma.ext ?_ ?_
  . sorry
  . sorry

def is_pb : IsPullback basePair (base.uvPolyTp.comp base.uvPolyTp).p base.tp baseSig := by
  sorry

def baseSigma : NaturalModelSigma base where
  Sig := baseSig
  pair := basePair
  Sig_pullback := is_pb

def smallUSigma : NaturalModelSigma smallU := sorry

def uHomSeqSigmas' (i : ℕ) (ilen : i < 4) :
  NaturalModelSigma (uHomSeqObjs i ilen) :=
  match i with
  | 0 => smallUSigma
  | 1 => smallUSigma
  | 2 => smallUSigma
  | 3 => baseSigma
  | (n+4) => by omega

end GroupoidModel
end
