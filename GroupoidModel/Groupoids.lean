/-
The category Grpd of (small) groupoids, as needed for the groupoid model of HoTT.

Here is Hofmann and Streicher's original paper:
https://ncatlab.org/nlab/files/HofmannStreicherGroupoidInterpretation.pdf

Here's something from the nLab that looks useful:
Ethan Lewis, Max Bohnet, The groupoid model of type theory, seminar notes (2017)
https://staff.fnwi.uva.nl/b.vandenberg3/Onderwijs/Homotopy_Type_Theory_2017/HoTT-bohnet-lewis-handout.pdf


See the thesis of Jakob Vidmar for polynomials and W-types in groupoids:
https://etheses.whiterose.ac.uk/22517/
-/
import Mathlib.CategoryTheory.ConcreteCategory.Bundled
import Mathlib.CategoryTheory.DiscreteCategory
import Mathlib.CategoryTheory.Types
import Mathlib.CategoryTheory.Bicategory.Strict
import Mathlib.CategoryTheory.Groupoid
import Mathlib.CategoryTheory.Category.Grpd


-- I added these import
import Mathlib.CategoryTheory.Grothendieck
import GroupoidModel.NaturalModel
import Mathlib.CategoryTheory.Category.Cat.Limit
--

universe u v u₁ v₁ u₂ v₂

namespace CategoryTheory

-- See Mathlib/CategoryTheory/Category/Grpd.lean

noncomputable section

/-!
# The category Grpd of groupoids
Need at least the following, some of which is already in MathLib:
  - the category of small groupoids and their homomorphisms
  - (discrete and split) fibrations of groupoids
  - pullbacks of (discrete and split) fibrations exist in Grpd and are again (such) fibrations
  - set- and groupoid-valued presheaves on groupoids
  - the Grothendieck construction relating the previous two
  - the equivalence between (split) fibrations and presheaves of groupoids
  - Σ and Π-types for (split) fibrations
  - path groupoids
  - the universe of (small) discrete groupoids (aka sets)
  - polynomial functors of groupoids
  - maybe some W-types
  - eventually we will want some groupoid quotients as well
  -/


@[simps?!]
def toCat {C : Type u₁} [Category.{v₁,u₁} C] (G : C ⥤ Grpd) : C ⥤ Cat := G ⋙ Grpd.forgetToCat

namespace Grothendieck

open CategoryTheory Iso

variable {C : Type u₁} [Category.{v₁,u₁} C] {G : C ⥤ Cat.{v₂,u₂}}

/-- A morphism in the Grothendieck construction is an isomorphism if the morphism in the base is an isomorphism and the fiber morphism is an isomorphism. -/
def mkIso {X Y : Grothendieck G} (s : X.base ≅ Y.base) (t : (G |>.map s.hom).obj X.fiber ≅ Y.fiber) :
    X ≅ Y where
  hom := { base := s.hom, fiber := t.hom }
  inv.base := s.inv
  inv.fiber := (G.map (s.inv)).map (t.inv) ≫
    eqToHom (by simpa only [Functor.map_comp, Functor.map_id] using
      congr((G.map $(s.hom_inv_id)).obj X.fiber))
  hom_inv_id := by
    apply ext
    erw [comp_fiber]
    simp only [Cat.comp_obj, id_eq, map_hom_inv_id_assoc,
      eqToHom_trans, id_fiber'] at *
    erw [comp_base, id_base]
    dsimp
    rw [s.hom_inv_id]
  inv_hom_id := by
    suffices ∀ {Z g} (_ : g ≫ s.hom = Z) (_ : Z = 𝟙 _)
        {g'} (eq : g' ≫ (G.map g).map t.hom = 𝟙 _)
        (W) (eqW : G.map g ≫ G.map s.hom = W)
        (eq2 : ∃ w1 w2, W.map t.hom = eqToHom w1 ≫ t.hom ≫ eqToHom w2) h1 h2,
        { base := Z, fiber := eqToHom h1 ≫ (G.map s.hom).map (g' ≫ eqToHom h2) ≫ t.hom } =
        ({..} : Grothendieck.Hom ..) from
      this rfl s.inv_hom_id (by simp)
        (W := 𝟙 _) (eqW := by simp) (eq2 := ⟨rfl, rfl, by simp⟩) ..
    rintro _ g - rfl g' eq _ rfl ⟨w1, w2, eq2 : (G.map s.hom).map _ = _⟩ h1 h2; congr
    replace eq := congr((G.map s.hom).map $eq)
    simp only [Functor.map_comp, eq2, eqToHom_map, Category.assoc] at eq ⊢
    conv at eq => lhs; slice 1 3
    rw [(comp_eqToHom_iff ..).1 eq]; simp

end Grothendieck

section
variable {C : Type u₁} [Groupoid.{v₁,u₁} C] {F : C ⥤ Grpd.{v₂,u₂}}

variable (F) in
/--
  In Mathlib.CategoryTheory.Grothendieck we find the Grothendieck construction
  for the functors `F : C ⥤ Cat`. Given a functor `F : G ⥤ Grpd`, we show that
  the Grothendieck construction of the composite `F ⋙ Grpd.forgetToCat`, where
  `forgetToCat : Grpd ⥤ Cat` is the embedding of groupoids into categories, is a groupoid.
-/
def GroupoidalGrothendieck := Grothendieck (toCat F)


namespace GroupoidalGrothendieck


instance : Category (GroupoidalGrothendieck F) := inferInstanceAs (Category (Grothendieck _))


instance (X : C) : Groupoid (toCat F |>.obj X) where
  inv f := ((F.obj X).str').inv f

def isoMk {X Y : GroupoidalGrothendieck F} (f : X ⟶ Y) : X ≅ Y := by
  fapply Grothendieck.mkIso
  · exact (Groupoid.isoEquivHom _ _).2 f.base
  · apply (Groupoid.isoEquivHom _ _).2 f.fiber

def inv {X Y : GroupoidalGrothendieck F} (f : X ⟶ Y) : Y ⟶ X  := isoMk f |>.inv

instance groupoid : Groupoid (GroupoidalGrothendieck F) where
  inv f :=  inv f
  inv_comp f := (isoMk f).inv_hom_id
  comp_inv f := (isoMk f).hom_inv_id


def forget : GroupoidalGrothendieck F ⥤ C :=
  Grothendieck.forget (F ⋙ Grpd.forgetToCat)
-- note: maybe come up with a better name?
def ToGrpd : GroupoidalGrothendieck F ⥤ Grpd.{v₂,u₂} := forget ⋙ F

def functorial {C D : Grpd.{v₁,u₁}} (F : C ⟶ D) (G : D ⥤ Grpd.{v₂,u₂})
  : Grothendieck (toCat (F ⋙ G)) ⥤ Grothendieck (toCat G) where
    obj X := ⟨F.obj X.base, X.fiber⟩
    map {X Y} f := ⟨F.map f.base, f.fiber⟩
    map_id X := by
      fapply Grothendieck.ext
      · exact F.map_id X.base
      · simp only [Grothendieck.id_fiber', eqToHom_trans]
    map_comp {X Y Z} f g := by
      simp only [Grothendieck.comp]
      fapply Grothendieck.ext
      · exact F.map_comp f.base g.base
      · erw [Grothendieck.comp_fiber (F:= toCat (F ⋙ G)) f g]
        simp [eqToHom_trans]
        erw [Grothendieck.comp_fiber]; rfl

end GroupoidalGrothendieck

end

section PointedCategorys

/-- The class of pointed pointed categorys. -/
class PointedCategory.{w,z} (C : Type z) extends Category.{w} C where
  pt : C

/-- A constructor that makes a pointed categorys from a category and a point. -/
def PointedCategory.of (C : Type*) (pt : C)[Category C]: PointedCategory C where
  pt := pt

/-- The structure of a functor from C to D along with a morphism from the image of the point of C to the point of D -/
@[ext]
structure PointedFunctor (C : Type*)(D : Type*)[cp : PointedCategory C][dp : PointedCategory D] extends C ⥤ D where
  point : obj (cp.pt) ⟶ (dp.pt)

/-- The identity `PointedFunctor` whoes underlying functor is the identity functor-/
@[simps!]
def PointedFunctor.id (C : Type*)[PointedCategory C] : PointedFunctor C C where
  toFunctor := Functor.id C
  point := 𝟙 PointedCategory.pt

/-- Composition of `PointedFunctor` that composes there underling functors and shows that the point is preserved-/
@[simps!]
def PointedFunctor.comp {C : Type*}[PointedCategory C]{D : Type*}[PointedCategory D]{E : Type*}[PointedCategory E]
  (F : PointedFunctor C D)(G : PointedFunctor D E)  : PointedFunctor C E where
  toFunctor := F.toFunctor ⋙ G.toFunctor
  point := (G.map F.point) ≫ (G.point)

theorem PointedFunctor.congr_func {C : Type*}[PointedCategory C]{D : Type*}[PointedCategory D]
  {F G: PointedFunctor C D}(eq : F = G)  : F.toFunctor = G.toFunctor := congrArg toFunctor eq

theorem PointedFunctor.congr_point {C : Type*}[pc :PointedCategory C]{D : Type*}[PointedCategory D]
  (F G: PointedFunctor C D)(eq : F = G)  : F.point = (eqToHom (Functor.congr_obj (congr_func eq) pc.pt)) ≫ G.point := by
    have h := (Functor.conj_eqToHom_iff_heq F.point G.point (Functor.congr_obj (congr_func eq) pc.pt) rfl).mpr
    simp at h
    apply h
    rw[eq]

/-- The category of pointed categorys and pointed functors-/
def PCat.{w,z} :=
  Bundled PointedCategory.{w, z}

namespace PCat

instance : CoeSort PCat.{v,u} (Type u) :=
  ⟨Bundled.α⟩

instance str (C : PCat.{v, u}) : PointedCategory.{v, u} C :=
  Bundled.str C

/-- Construct a bundled `PCat` from the underlying type and the typeclass. -/
def of (C : Type u) [PointedCategory C] :  PCat.{v, u} :=
  Bundled.of C

instance category : LargeCategory.{max v u} PCat.{v, u} where
  Hom C D := PointedFunctor C D
  id C := PointedFunctor.id C
  comp f g := PointedFunctor.comp f g

/-- The functor that takes PCat to Cat by forgeting the points-/
def forgetPoint : PCat ⥤ Cat where
  obj x := Cat.of x
  map f := f.toFunctor

end PCat

/-- The class of pointed pointed groupoids. -/
class PointedGroupoid.{w,z} (C : Type z) extends Groupoid.{w} C, PointedCategory.{w,z} C

/-- A constructor that makes a pointed groupoid from a groupoid and a point. -/
def PointedGroupoid.of (C : Type*) (pt : C) [Groupoid C]: PointedGroupoid C where
  pt := pt

/-- The category of pointed groupoids and pointed functors-/
def PGrpd.{w,z} :=
  Bundled PointedGroupoid.{w, z}

namespace PGrpd

instance : CoeSort PGrpd.{v,u} (Type u) :=
  ⟨Bundled.α⟩

instance str (C : PGrpd.{v, u}) : PointedGroupoid.{v, u} C :=
  Bundled.str C

/-- Construct a bundled `PGrpd` from the underlying type and the typeclass. -/
def of (C : Type u) [PointedGroupoid C] : PGrpd.{v, u} :=
  Bundled.of C

instance category : LargeCategory.{max v u} PGrpd.{v, u} where
  Hom C D := PointedFunctor C D
  id C := PointedFunctor.id C
  comp f g := PointedFunctor.comp f g

/-- The functor that takes PGrpd to Grpd by forgeting the points-/
def forgetPoint : PGrpd ⥤ Grpd where
  obj x := Grpd.of x
  map f := f.toFunctor

end PGrpd

end PointedCategorys

section NaturalModelBase

-- This is a Covariant Functor that takes a Groupoid Γ to Γ ⥤ Grpd
def Ty_functor : Grpd.{u,u}ᵒᵖ ⥤ Type (u + 1) where
  obj x := x.unop ⥤ Grpd.{u,u}
  map f A := f.unop ⋙ A

-- This is a Covariant Functor that takes a Groupoid Γ to Γ ⥤ PointedGroupoid
def Tm_functor : Grpd.{u,u}ᵒᵖ ⥤ Type (u + 1) where
  obj x := x.unop ⥤ PGrpd.{u,u}
  map f A := f.unop ⋙ A

-- This is the typing natral transformation
def tp_NatTrans : NatTrans Tm_functor Ty_functor where
  app x := by
    intro a
    exact a ⋙ PGrpd.forgetPoint

-- This is the var construction of var before applying yoneda
def var' (Γ : Grpd)(A : Γ ⥤ Grpd) : (GroupoidalGrothendieck A) ⥤ PGrpd where
  obj x := ⟨(A.obj x.base), (PointedGroupoid.of (A.obj x.base) x.fiber)⟩
  map f := ⟨A.map f.base, f.fiber⟩
  map_id x := by
    dsimp [CategoryStruct.id]
    congr 1
    · simp only [A.map_id]; rfl
    · exact cast_heq (Eq.symm (eqToHom.proof_1 (Grothendieck.id.proof_1 x))) (𝟙 x.fiber)
  map_comp {X Y Z} f g := by
    dsimp [CategoryStruct.comp,PointedFunctor.comp]
    congr 1
    exact A.map_comp f.base g.base
    dsimp [eqToHom]
    have h := (Category.id_comp ((A.map g.base).map f.fiber ≫ g.fiber))
    rw [← h]
    congr 1
    simp [Grpd.forgetToCat, CategoryStruct.comp]
    exact
      cast_heq (Eq.symm (eqToHom.proof_1 (Grothendieck.comp.proof_1 f g)))
        (𝟙
          ((Grpd.forgetToCat.map (A.map g.base)).obj
            ((Grpd.forgetToCat.map (A.map f.base)).obj X.fiber)))


def Lift_dom {Γ : Type u}[Category.{u} Γ]{C : Type (u+1)}[Category.{u} C](A : Γ ⥤ C) : (ULift.{u+1,u} Γ) ⥤ C where
  obj x := A.obj x.down
  map f := A.map f
  map_id x := by
    simp[CategoryStruct.id]
  map_comp f g := by
    simp[CategoryStruct.comp]

def Lift_domcod {Γ Δ: Type u}[Category.{u} Γ][Category.{u} Δ](F : Γ ⥤ Δ) : (ULift.{u+1,u} Γ) ⥤ (ULift.{u+1,u} Δ) where
  obj x := {down := F.obj x.down}
  map f := F.map f
  map_id x := by
    simp[CategoryStruct.id]
  map_comp f g := by
    simp[CategoryStruct.comp]

def CastFunc {C : Cat.{u+1,u}}{F1 : C ⥤ Grpd.{u,u}}{F2 : C ⥤ Grpd.{u,u}}(Comm : F1 = F2 )(x : C) : Equivalence (F1.obj x) (F2.obj x) := by
  have h := @Cat.equivOfIso (Grpd.forgetToCat.obj (F1.obj x)) (Grpd.forgetToCat.obj (F2.obj x)) (eqToIso (congrArg Grpd.forgetToCat.obj (Functor.congr_obj Comm x)))
  dsimp[Grpd.forgetToCat,Cat.of,Bundled.of] at h
  exact h

def GrpdHelp (P : PGrpd.{u,u}) : P ⥤ (PGrpd.forgetPoint.obj P) := by
  simp[PGrpd.forgetPoint]
  exact Functor.id P

def PB.vallift {Γ : Grpd.{u,u}}(A : Γ ⥤ Grpd.{u,u})(C : Cat.{u+1,u})(F1 : C ⥤ PGrpd.{u,u})(F2 : C ⥤ Γ)(Comm : F1 ⋙ PGrpd.forgetPoint = F2 ⋙ A) : C ⥤ GroupoidalGrothendieck A where
  obj x := {base := (F2.obj x), fiber := ((GrpdHelp (F1.obj x)) ⋙ (CastFunc Comm x).functor).obj ((F1.obj x).str.pt)}
  map f := by
    rename_i X Y
    refine {base := F2.map f, fiber := (eqToHom ?_) ≫ (((CastFunc Comm Y).functor).map (F1.map f).point)}
    dsimp
    have leftEQ : (Grpd.forgetToCat.map (A.map (F2.map f))).obj ((CastFunc Comm X).functor.obj ((GrpdHelp (F1.obj X)).obj (@PointedGroupoid.pt ((F1.obj X)) (F1.obj X).str))) =
     ((GrpdHelp (F1.obj X)) ⋙ (CastFunc Comm X).functor ⋙ (Grpd.forgetToCat.map ((F2 ⋙ A).map f))).obj (@PointedGroupoid.pt (F1.obj X) (F1.obj X).str) := rfl
    rw[leftEQ,(Functor.congr_hom Comm.symm f),Grpd.forgetToCat.map_comp,Grpd.forgetToCat.map_comp,eqToHom_map]
    have eqToHomFunctorHelp : (CastFunc Comm X).functor ⋙ eqToHom (congr_arg Grpd.forgetToCat.obj (Functor.congr_obj (Eq.symm Comm) X)) = 𝟙 (Grpd.forgetToCat.obj (PGrpd.forgetPoint.obj (F1.obj X))) := by
      have h : ∀ {X Y Z : Cat} (p : X = Y) (q : Y = Z), eqToHom p ≫ eqToHom q = eqToHom (p.trans q) := @eqToHom_trans Cat.{u,u} _
      dsimp [CategoryStruct.comp] at h
      simp [CastFunc,Cat.equivOfIso,h]
    dsimp only [CategoryStruct.comp]
    rw [<- Functor.assoc ((CastFunc Comm X).functor),eqToHomFunctorHelp]
    simp [CategoryStruct.id]
    aesop_cat
  map_id x := by
    simp[CategoryStruct.id,Grothendieck.id]
    apply Grothendieck.ext
    simp only [Grothendieck.Hom.fiber]
    simp[(dcongr_arg PointedFunctor.point (F1.map_id x)),eqToHom_map,CategoryStruct.id]
    exact F2.map_id x
  map_comp f g := by
    rename_i X Y Z
    dsimp[CategoryStruct.comp,Grothendieck.comp]
    apply Grothendieck.ext
    have h := @PointedFunctor.congr_point (F1.obj X) _ (F1.obj Z) _ (F1.map (f ≫ g)) ((F1.map f)≫(F1.map g)) (F1.map_comp f g)
    have h'' := (congrArg Grpd.forgetToCat.map (Functor.congr_hom Comm.symm g))
    simp only [Functor.map_comp, eqToHom_map] at h''
    have h' := Functor.congr_hom h'' ((CastFunc Comm Y).functor.map (F1.map f).point)
    dsimp at h'
    simp[Grothendieck.Hom.fiber,h,CategoryStruct.comp,eqToHom_map,h']
    sorry
    exact F2.map_comp f g

abbrev LimDiag {Γ : Grpd.{u,u}}(A : Γ ⥤ Grpd.{u,u}) := (@CategoryTheory.Limits.PullbackCone Cat.{u,u+1} _ (Cat.of PGrpd.{u,u}) (Cat.of (ULift.{u+1,u} Γ)) (Cat.of Grpd.{u,u}) PGrpd.forgetPoint.{u,u} (Lift_dom A))

def Lim {Γ : Grpd.{u,u}}(A : Γ ⥤ Grpd.{u,u}): (LimDiag A) where
  pt := (Cat.of (ULift.{u+1,u} (GroupoidalGrothendieck A)))
  π := by
    constructor
    case app;
    intro X
    cases X
    case app.some;
    rename_i X
    cases X
    dsimp
    exact (Lift_dom (var' Γ A))
    dsimp
    exact (Lift_domcod GroupoidalGrothendieck.forget)
    exact (Lift_domcod GroupoidalGrothendieck.forget) ⋙ (Lift_dom A)
    intros X Y f
    dsimp
    cases f
    simp
    rename_i X
    cases X
    aesop_cat
    aesop_cat


def isLim {Γ : Grpd.{u,u}}(A : Γ ⥤ Grpd.{u,u}) : Limits.IsLimit (Lim A) := by
  refine Limits.PullbackCone.isLimitAux' (Lim A) ?_
  intro s
  constructor
  case val;
  dsimp [Lim,Quiver.Hom,Cat.of,Bundled.of]
  let FL := (s.π).app (Option.some Limits.WalkingPair.left)
  let FR := (s.π).app (Option.some Limits.WalkingPair.right)
  let FM := (s.π).app (Option.some Limits.WalkingPair.right)
  dsimp [Quiver.Hom] at FL FR FM
  let Comm := (s.π).naturality
  sorry
  dsimp
  refine ⟨?_,?_,?_⟩
  sorry
  sorry
  sorry


theorem PB {Γ : Grpd.{u,u}}(A : Γ ⥤ Grpd.{u,u}): @IsPullback Cat.{u,u+1} _ (Cat.of (ULift.{u+1,u} (GroupoidalGrothendieck A))) (Cat.of PGrpd.{u,u}) (Cat.of (ULift.{u+1,u} Γ)) (Cat.of Grpd.{u,u}) (Lift_dom (var' Γ A)) (Lift_domcod GroupoidalGrothendieck.forget) PGrpd.forgetPoint (Lift_dom A) where
  w := rfl
  isLimit' := by
    constructor
    constructor
    case val.lift;
    intro s



open GroupoidalGrothendieck

-- Here I am useing sGrpd to be a small category version of Grpd. There is likely a better way to do this.
def sGrpd := ULiftHom.{u+1} Grpd.{u,u}
  deriving SmallCategory

def sGrpd.of (C : Type u) [Groupoid.{u} C] : sGrpd.{u} := Grpd.of C

def SmallGrpd.forget : sGrpd.{u} ⥤ Grpd.{u,u} where
  obj x := Grpd.of x.α
  map f := f.down

/-
This is the Natural Model on sGrpd. I am not sure this belongs in this file but I keep it here so that I can
get an idea of what needs to be done.
-/
instance GroupoidNM : NaturalModel.NaturalModelBase sGrpd.{u} where
  Ty := SmallGrpd.forget.op ⋙ Ty_functor
  Tm := SmallGrpd.forget.op ⋙ Tm_functor
  tp := NatTrans.hcomp (NatTrans.id SmallGrpd.forget.op) (tp_NatTrans)
  ext Γ f := sGrpd.of (GroupoidalGrothendieck ((@yonedaEquiv _ _ Γ (SmallGrpd.forget.op ⋙ Ty_functor)).toFun f))
  disp Γ A := by
    constructor
    exact Grothendieck.forget (yonedaEquiv A ⋙ Grpd.forgetToCat)
  var Γ A := yonedaEquiv.invFun (var' (SmallGrpd.forget.obj Γ) (yonedaEquiv A))
  disp_pullback A := by
    dsimp
    sorry

end NaturalModelBase

instance groupoidULift.{u'} {α : Type u} [Groupoid.{v} α] : Groupoid (ULift.{u'} α) where
  inv f := Groupoid.inv f
  inv_comp _ := Groupoid.inv_comp ..
  comp_inv _ := Groupoid.comp_inv ..

instance groupoidULiftHom.{u'} {α : Type u} [Groupoid.{v} α] : Groupoid (ULiftHom.{u'} α) where
  inv f := .up (Groupoid.inv f.down)
  inv_comp _ := ULift.ext _ _ <| Groupoid.inv_comp ..
  comp_inv _ := ULift.ext _ _ <| Groupoid.comp_inv ..

inductive Groupoid2 : Type (u+2) where
  | small (_ : sGrpd.{u})
  | large (_ : sGrpd.{u+1})

def Groupoid2.toLarge : Groupoid2.{u} → sGrpd.{u+1}
  | .small A => .mk (ULiftHom.{u+1} (ULift.{u+1} A.α))
  | .large A => A

/-- A model of Grpd with an internal universe, with the property that the small universe
injects into the large one. -/
def Grpd2 : Type (u+2) := InducedCategory sGrpd.{u+1} Groupoid2.toLarge
  deriving SmallCategory
