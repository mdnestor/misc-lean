universe u v
structure Cat where
  obj: Type u
  hom (_ _: obj) : Type v
  id (a: obj): hom a a
  comp (a b c: obj) (f: hom a b) (g: hom b c): hom a c
  left_id_law (a b: obj) (f: hom a b):
    f = comp a a b (id a) f
  right_id_law (a b: obj) (f: hom a b):
    f = comp a b b f (id b)
  assoc_law (a b c d: obj) (f: hom a b) (g: hom b c) (h: hom c d):
    comp a b d f (comp b c d g h) = comp a c d (comp a b c f g) h

structure Mon where
  elem: Type
  id: elem
  op: elem -> elem -> elem
  left_id_law (x: elem): op e x = x
  right_id_law (x: elem): op e x = x
  assoc_law (x y z: elem): op x (op y z) = op (op x y) z
structure MonMorph (M1 M2: Mon) where
  func: M1.elem -> M2.elem
  id_law: func M1.id = M2.id
  op_law (x y: M1.elem): func (M1.op x y) = M2.op (func x) (func y)
def mon_id (M: Mon) : MonMorph M M := {
  func := fun x => x,
  id_law := rfl,
  op_law := by {intros; simp}
}
def mon_comp (M1 M2 M3: Mon) (f1: MonMorph M1 M2) (f2: MonMorph M2 M3): MonMorph M1 M3 := {
  func := fun x => f2.func (f1.func x),
  id_law := by {intros; simp; rw [f1.id_law, f2.id_law]},
  op_law := by {intros; simp; rw[f1.op_law, f2.op_law]}
}
def category_of_monoids: Cat := {
  obj := Mon,
  hom := by {intro M1 M2; exact MonMorph M1 M2},
  id := by {intro M; exact mon_id M},
  comp := by {intro M1 M2 M3 f1 f2; exact mon_comp M1 M2 M3 f1 f2},
  left_id_law := by {intros; rw [mon_comp, mon_id]},
  right_id_law := by {intros; rw [mon_comp, mon_id]},
  assoc_law := by {intros; rw [mon_comp, mon_comp, mon_comp, mon_comp]}
}

/- A dynamical system is the action of a monoid on a type -/
structure DynSys where
  state: Type
  time: Mon
  rule: time.elem -> state -> state
  id_law (x: state): rule time.id x = x
  action_law (x: state) (t1 t2: time.elem): rule t2 (rule t1 x) = rule (time.op t2 t1) x

/- Homomorphism of dynamical systems -/
structure DynSysMorph (S1 S2: DynSys) where
  func: S1.state -> S2.state
  morph: MonMorph S1.time S2.time
  ok (x: S1.state) (t: S1.time.elem): func (S1.rule t x) = S2.rule (morph.func t) (func x)

def dynsys_id (S: DynSys) : DynSysMorph S S := {
  func := fun x => x,
  morph := mon_id S.time
  ok := by {intros; rfl}
}
def dynsys_comp (S1 S2 S3: DynSys) (f1: DynSysMorph S1 S2) (f2: DynSysMorph S2 S3): DynSysMorph S1 S3 := {
  func := fun x => f2.func (f1.func x),
  morph := mon_comp S1.time S2.time S3.time f1.morph f2.morph,
  ok := by {intros; simp; rw [mon_comp, f1.ok, f2.ok]}
}

def category_of_dynamical_systems: Cat := {
  obj := DynSys,
  hom := by {intro S1 S2; exact DynSysMorph S1 S2},
  id := by {intro S; exact dynsys_id S},
  comp := by {intro S1 S2 S3 f1 f2; exact dynsys_comp S1 S2 S3 f1 f2},
  left_id_law := by {intros; rfl},
  right_id_law := by {intros; rfl},
  assoc_law := by {intros; rfl}
}
