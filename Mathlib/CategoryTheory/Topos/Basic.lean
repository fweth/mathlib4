/-
Copyright (c) 2025 Klaus Gy. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Klaus Gy
-/
import Mathlib.CategoryTheory.Limits.Shapes.Pullback.Equalizer
import Mathlib.CategoryTheory.Opposites
import Mathlib.CategoryTheory.Topos.Classifier

/-!
# Elementary Topos (in Elementary Form)

This ongoing work formalizes the elementary definition of a topos and the direct consequences.

## References

* [S. MacLane and I. Moerdijk, *Sheaves in Geometry and Logic*][MM92]
-/


universe u v u₀ v₀

namespace CategoryTheory

open Category Limits Functor

local notation "𝟙⨯ " f => prod.map (𝟙 _) f
local notation f " ⨯𝟙" => prod.map f (𝟙 _)

/-- A category `ℰ` is an elementary topos if it has finite limits
and satisfies a power object condition relative to a fixed subobject classifier `Ω`.

See MM92, Chapter IV, Section 1. -/
class ElementaryTopos (ℰ : Type u) [Category.{v} ℰ] [HasFiniteLimits ℰ] where
  /-- A fixed choice of subobject classifier in `ℰ`, supplying mainly
  `Ω`, `true : ⊤_ C ⟶ Ω`, and `χ` to build the characteristic map. -/
  hc : Classifier ℰ
  /-- Power objects, will become a functor `P : ℰᵒᵖ ⥤ ℰ` later . -/
  P (B : ℰ) : ℰ
  /-- The element relation. -/
  ε_ (B : ℰ) : B ⨯ (P B) ⟶ hc.Ω
  /-- The P-transpose of a morphism `f : B × A ⟶ Ω`. See equation (6) of MM92. -/
  unhat {A B : ℰ} (f : B ⨯ A ⟶ hc.Ω) : (A ⟶ P B)
  /-- Characteristic equation: any `f : B × A ⟶ Ω` is equal to `ε_B ∘ (𝟙 ⨯ g)`
      where `g` is the P-transpose of `f`. -/
  comm {A B : ℰ} (f : B ⨯ A ⟶ hc.Ω) :
    f = (𝟙⨯ (unhat f)) ≫ ε_ B
  /-- Uniqueness: the P-transpose `g : A ⟶ P B` is uniquely determined by `f`. -/
  uniq {A B : ℰ} (f : B ⨯ A ⟶ hc.Ω) (g : A ⟶ P B)
    (_ : f = (𝟙⨯ g) ≫ ε_ B) : g = (unhat f)

variable {ℰ : Type u} [Category.{v} ℰ] [HasFiniteLimits ℰ] [ElementaryTopos ℰ]

open ElementaryTopos

noncomputable section

/-- The morphism `ε_B ∘ (𝟙 × g)` associated to a map `g : A ⟶ P B`.
    This is the inverse direction of the transpose isomorphism. -/
def hat {A : ℰ} (B : ℰ) (g : A ⟶ P B) : B ⨯ A ⟶ hc.Ω := (𝟙⨯ g) ≫ ε_ B

/-- The morphism `P_morph h` is the functorial action on a morphism `h : B ⟶ C`,
    defined as the P-transpose of `∘ ε_C ∘ h ⨯ 𝟙`. -/
def P_morph {B C : ℰ} (h : B ⟶ C) : P C ⟶ P B := unhat ((h ⨯𝟙) ≫ ε_ C)

/-- Naturality (dinaturality) of `ε`. This corresponds to the naturality square of ε
    in MM92 diagram (5). -/
lemma ε_dinaturality {B C : ℰ} (h : B ⟶ C) :
  (h ⨯𝟙) ≫ ε_ C = (𝟙⨯ (P_morph h)) ≫ ε_ B := comm _

/-- `P` covariantly preserves composition, shown by stacking dinaturality squares. -/
private lemma P_compose {B C D : ℰ} (h : B ⟶ C) (h' : C ⟶ D) :
    P_morph (h ≫ h') = P_morph h' ≫ P_morph h :=
  let comm_left : (h ⨯𝟙) ≫ (𝟙⨯ (P_morph h')) = (𝟙⨯ (P_morph h')) ≫ (h ⨯𝟙) := by simp
  let comm_outer : (h ⨯𝟙) ≫ (h' ⨯𝟙) ≫ ε_ D = (𝟙⨯ (P_morph h')) ≫ (𝟙⨯ (P_morph h)) ≫ ε_ B :=
    by rw [ε_dinaturality h', ← assoc, comm_left, assoc, ε_dinaturality h]
  let eq : (𝟙⨯ (P_morph h')) ≫ (𝟙⨯ (P_morph h)) ≫ ε_ B =
      (𝟙⨯ P_morph h' ≫ P_morph h) ≫ ε_ B := by rw [← assoc, prod.map_id_comp]
  by rw [P_morph, prod.map_comp_id, assoc, comm_outer, ← uniq _ _ eq]

open Opposite

/-- The power object functor `P : ℰᵒᵖ ⥤ ℰ` defined from `P` and `P_morph`. -/
def P_functor : ℰᵒᵖ ⥤ ℰ := {
  obj B := P (unop B),
  map h := P_morph h.unop,
  map_id B := Eq.symm (uniq _ _ (by rfl)),
  map_comp {B C D : ℰᵒᵖ} (h : B ⟶ C) (h' : C ⟶ D) := P_compose h'.unop h.unop
}

/--
Given morphisms `g : A ⟶ P C` and `h : B ⟶ C`, if `g^` is the characteristic map of a subobject
`U ↪ C ⨯ A`, then the transpose `(Ph ∘ g)^ : B ⨯ A ⟶ Ω` is the characteristic map of the pullback
of `U` along `h ⨯ 𝟙`. Flipping the classifier squares to follow the diagram layout in the book.
-/
theorem char_of_pullback {A B C U : ℰ} (g : A ⟶ P C) (h : B ⟶ C) (m : U ⟶ C ⨯ A) [Mono m]
    (isChar : hat C g = hc.χ m) :
    hat B (g ≫ P_morph h) = hc.χ (pullback.snd m (h ⨯𝟙)) :=
  let pb_right := IsPullback.flip (hc.isPullback m)
  let pb_left := IsPullback.of_hasPullback m (h ⨯𝟙)
  let pb_outer := IsPullback.paste_horiz pb_left pb_right
  let eq₁ : (𝟙⨯ g) ≫ (h ⨯𝟙) = (h ⨯𝟙) ≫ (𝟙⨯ g) := by simp
  let eq₂ : (h ⨯𝟙) ≫ (hat _ g) = hc.χ (pullback.snd m (h ⨯𝟙)) :=
    hc.uniq (pullback.snd m (h ⨯𝟙)) (IsPullback.flip (by simpa [isChar] using pb_outer))
  by rw [hat, prod.map_id_comp, assoc, ← ε_dinaturality, reassoc_of% eq₁, ← hat, eq₂]

def δ_ (B : ℰ) : B ⨯ B ⟶ hc.Ω := hc.χ (diag B)
def sing (B : ℰ) : B ⟶ P B := unhat (δ_ B)

local notation "⟨𝟙⨯ " f "⟩" => prod.lift (𝟙 _) f
local notation "⟨" f " ⨯𝟙⟩" => prod.lift f (𝟙 _)
local notation "Δ" => Limits.diag

variable {C : Type u} [Category.{v} C] [HasFiniteLimits C]

private lemma pullback_of_diag {B X : C} (b : X ⟶ B) : IsPullback b ⟨b ⨯𝟙⟩ (Δ B) (𝟙⨯ b) :=
  have : IsLimit (Fork.ofι ⟨b ⨯𝟙⟩ ((by simp) : ⟨b ⨯𝟙⟩ ≫ prod.fst = ⟨b ⨯𝟙⟩ ≫ prod.snd ≫ b)) :=
    Fork.IsLimit.mk _
    (fun s => s.ι ≫ prod.snd)
    (fun s => ((by simp[prod.comp_lift, ← s.condition])))
    (fun s m eq => by simp[← eq])
  IsPullback.flip (Limits.isPullback_equalizer_prod' prod.fst (prod.snd ≫ b) _ _)

-- private lemma pullback_of_diag {B X : C} (b : X ⟶ B) : IsPullback b ⟨b ⨯𝟙⟩ (Δ B) (𝟙⨯ b) :=
--   let cs : CommSq  b ⟨b ⨯𝟙⟩ (Δ B) (𝟙⨯ b) := by simp
--   let eq₁ (s : PullbackCone (Δ B) (𝟙⨯ b)) : (s.snd ≫ prod.snd) ≫ b = s.fst :=
--     by calc
--       (s.snd ≫ prod.snd) ≫ b = s.snd ≫ (𝟙⨯ b) ≫ prod.snd := by simp
--       _ = (s.fst ≫ Δ B) ≫ prod.snd := by rw [← assoc, ← s.condition]
--       _ = s.fst := by simp
--   let eq₂ (s : PullbackCone (Δ B) (𝟙⨯ b)) : (s.snd ≫ prod.snd) ≫ prod.lift b (𝟙 X) = s.snd :=
--     have : (s.snd ≫ prod.snd) ≫ b = s.snd ≫ prod.fst :=
--       by calc
--         _ = s.fst ≫ Δ B ≫ prod.fst := by simp[eq₁]
--         _ = s.snd ≫ (𝟙⨯ b) ≫ prod.fst := by rw[← assoc, s.condition, assoc]
--         _ = s.snd ≫ prod.fst := by simp
--     by simp[this]

--   IsPullback.of_isLimit'
--     cs (PullbackCone.IsLimit.mk _
--     (fun s => s.snd ≫ prod.snd) eq₁ eq₂ (fun _ _ _ eq => by simp [← eq]))


instance {B : ℰ} : Mono (sing B) :=
  ⟨ fun b b' w =>
    let pb : IsPullback b ⟨b ⨯𝟙⟩ (diag B) (𝟙⨯ b) := sorry
    have : (𝟙⨯ b) ≫ (δ_ B) = (𝟙⨯ b') ≫ (δ_ B) := sorry
    sorry
  ⟩


end
end CategoryTheory
