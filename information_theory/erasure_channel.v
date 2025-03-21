(* infotheo: information theory and error-correcting codes in Coq              *)
(* Copyright (C) 2020 infotheo authors, license: LGPL-2.1-or-later             *)
From mathcomp Require Import all_ssreflect ssralg fingroup finalg perm zmodp.
From mathcomp Require Import matrix.
Require Import Reals.
From mathcomp Require Import Rstruct.
Require Import ssrR Reals_ext ssr_ext ssralg_ext logb Rbigop fdist entropy.
Require Import binary_entropy_function channel hamming channel_code.

(******************************************************************************)
(*                     Definition of erasure channel                          *)
(*                                                                            *)
(* EC.v == definition of n-ary Erasure Channel (EC)                           *)
(*                                                                            *)
(******************************************************************************)

Set Implicit Arguments.
Unset Strict Implicit.
Import Prenex Implicits.

Local Open Scope channel_scope.
Local Open Scope R_scope.
Local Open Scope reals_ext_scope.

Module EC.

Section EC_sect.
Variables (A : finType) (p : R).
Hypothesis p_01 : 0 <= p <= 1.

Definition f (a : A) := [ffun b =>
  if b is Some a' then
    if a == a' then p.~ else 0
  else p].

Lemma f0 a b : 0 <= f a b.
Proof.
rewrite /f ffunE.
case: b => [a'|]; last by case: p_01.
case: ifP => _.
case: p_01 => ? ?; exact/onem_ge0.
exact/leRR.
Qed.

Lemma f1 (a : A) : \sum_(a' : {:option A}) f a a' = 1.
Proof.
rewrite (bigD1 None) //= (bigD1 (Some a)) //= !ffunE eqxx /= (proj2 (psumR_eq0P _)).
- by rewrite addR0 onemKC.
- rewrite /f; case => [a'|]; last by case: p_01.
  rewrite ffunE.
  case: ifPn => [_ |*]; last exact/leRR.
  case: p_01 => ? ? _; exact/onem_ge0.
- case => //= a' aa'; rewrite ffunE; case: ifPn => // /eqP ?; subst a'.
  move: aa'; by rewrite eqxx.
Qed.

Definition c : `Ch(A, [finType of option A]) :=
  fun a => FDist.make (f0 a) (f1 a).

End EC_sect.

Section EC_prob.

Variable X : finType.
Hypothesis card_X : #|X| = 2%nat.
Variables (P : fdist X) (p : R) (* erasure probability *).
Hypothesis p_01 : 0 <= p <= 1.

Let BEC := @EC.c X p p_01.
Let q := P (Set2.a card_X).
Local Notation W := (EC.f p).
Local Notation P'W := (P `X BEC)%fdist.
Local Notation PW := (`O(P, BEC)).

Lemma EC_non_flip (a : X) (i : option X):
  (i != None) && (i != Some a) -> 0 = EC.f p a i.
Proof.
case: i => //= x xa; rewrite ffunE; case: ifP => // ax; move: xa.
by rewrite (eqP ax) eqxx.
Qed.

End EC_prob.

End EC.
