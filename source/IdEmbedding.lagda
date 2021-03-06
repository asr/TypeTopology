Martin Escardo, 2015, formalized December 2017.

Id : X → (X → U) is an embedding assuming functional extensionality,
and either univalence or K, in fact the Yoneda Embedding.

The Id-fiber of A:X→U ̇ says that A is representable, which is
equivalent to the contractibility of ΣA, which is a
proposition. (Hence the injective types are the retracts of the
exponential powers of the universe.)

This works as follows in outline:

If A : X → U ̇ then the Id-fiber of A is Σ \(x : X) → Id x ≡ A.

If (x : X , p : Id x = A) is in the fiber, then

   ap Σ p : Σ (Id x) = Σ A,

and hence, being equal to a contractible type, Σ A is
contractible.

Next we have (*)

 A x ≃ Nat (Id x) A             (yoneda)
     = (y : Y) → Id x y → A y   (definition)
     ≃ (y : Y) → Id x y ≃ A y   (because Σ A is contractible (Yoneda corollary))
     ≃ (y : Y) → Id x y ≡ A y   (by univalence)
     ≃ Id x ≡ A                 (by function extensionality)

Hence the type Σ \(x : X) → Id x ≡ A y is contractible, because Σ A is
contractible, which shows that Id : X → (X → U) is an embedding.

2017:

This relies on univalence. But less than that suffices
(https://groups.google.com/forum/#!topic/homotopytypetheory/bKti7krHM-c)

First, Evan Cavallo showed that it is enough to assume funext and that
the canonical map X ≡ Y → X ≃ Y is an embedding. Then, using this idea
and the above proof outline, we further generalized this to assume
that the canonical map X ≡ Y → (X → Y) is left-cancellable (which is
much weaker than assuming that it is an embedding).

This is what we record next (9th December 2017), using the original
idea (*) in the weakened form discussed above.

\begin{code}

open import UF

module IdEmbedding where

\end{code}

The Id Embedding Lemma. The idea is to show that the type 
T := Σ \(x : X) → Id x ≡ A is a proposition by showing that there is a
left-cancellable map from it to a proposition, namely the contractible
type Σ A.

\begin{code}

Id-Embedding-Lemma : ∀ {U} → FunExt U U → FunExt U (U ′) → {X : U ̇}
                  → ((x y : X) (A : X → U ̇)
                  → left-cancellable (idtofun (Id x y) (A y))) 
                  → isEmbedding(Id {U} {X})
Id-Embedding-Lemma {U} fe fe' {X} iflc A (x₀ , p₀) = h (x₀ , p₀)
 where
  T = Σ \(x : X) → Id x ≡ A
  q : Σ (Id x₀) ≡ Σ A
  q = ap Σ p₀
  c : isContr(Σ A)
  c = yoneda-nat isContr (paths-from-contractible x₀) (Σ A) q
  f₀ : (x : X) → Id x ≡ A → (y : X) → Id x y ≡ A y
  f₀ x = happly (Id x) A
  f₁ : (x : X) → ((y : X) → Id x y ≡ A y) → Nat (Id x) A
  f₁ x = NatΠ (λ y → idtofun (Id x y) (A y))
  f₂ : (x : X) → Nat (Id x) A → A x
  f₂ x = yoneda-elem A
  f : (x : X) → Id x ≡ A → A x
  f x = f₂ x ∘ f₁ x ∘ f₀ x
  f₀-lc : (x : X) → left-cancellable(f₀ x)
  f₀-lc x = happly-lc fe' (Id x) A
  f₁-lc : (x : X) → left-cancellable(f₁ x)
  f₁-lc x = g
    where
      l : ∀ {φ φ'} → f₁ x φ ≡ f₁ x φ' → (x : X) → φ x ≡ φ' x
      l {φ} {φ'} = NatΠ-lc (λ y → idtofun (Id x y) (A y)) (λ y → iflc x y A)
      g : ∀ {φ φ'} → f₁ x φ ≡ f₁ x φ' → φ ≡ φ'
      g p = funext fe' (l p) 
  f₂-lc : (x : X) → left-cancellable(f₂ x)
  f₂-lc x {η} {η'} p = funext fe (λ y → funext fe (l y))
    where
      l : η ≈ η'
      l = yoneda-elem-lc η η' p
  f-lc : (x : X) → left-cancellable(f x)
  f-lc x = lcccomp (f₀ x) (f₂ x ∘ f₁ x) (f₀-lc x) (lcccomp (f₁ x) (f₂ x) (f₁-lc x) (f₂-lc x))
  g : T → Σ A
  g = NatΣ f 
  g-lc : left-cancellable g
  g-lc = NatΣ-lc X (λ x → Id x ≡ A) A f f-lc 
  h : isProp T
  h = lcmtpip g g-lc (c-is-p c)

\end{code}

Univalence implies that the function Id {U} {X} : X → (X → U ̇) is an embedding.
  
\begin{code}

UA-Id-embedding-Theorem : ∀ {U} → isUnivalent U → FunExt U U → FunExt U (U ′) 
                       → {X : U ̇} → isEmbedding(Id {U} {X})
UA-Id-embedding-Theorem {U} ua fe fe' {X} = Id-Embedding-Lemma fe fe' 
                                            (λ x y a → isUnivalent-idtofun-lc ua fe (Id x y) (a y))

\end{code}

The K axiom and function extensionality together imply that the
function Id : X → (X → U) is an embedding.

\begin{code}

K-id-embedding-Theorem' : ∀ {U} → K (U ′) → FunExt U U → FunExt U (U ′) 
                       → {X : U ̇} → isEmbedding(Id {U} {X})
K-id-embedding-Theorem' {U} k fe fe' {X} = Id-Embedding-Lemma fe fe' (K-idtofun-lc k) 

\end{code}

But actually function extensionality is not needed for this: K alone suffices.

\begin{code}

Id-lc : ∀ {U} {X : U ̇} → left-cancellable (Id {U} {X})
Id-lc {U} {X} {x} {y} p = idtofun (Id y y) (Id x y) (happly (Id y) (Id x) (p ⁻¹) y) (idp y)

K-id-embedding-Theorem : ∀ {U} → K (U ′) → {X : U ̇} → isEmbedding(Id {U} {X})
K-id-embedding-Theorem {U} k {X} = K-lc-e Id Id-lc k

\end{code}
