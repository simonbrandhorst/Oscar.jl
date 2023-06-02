########################################################################
#
# (1) AbsSpec interface
#
########################################################################

@doc raw"""
    underlying_scheme(X::AffineAlgebraicSet) -> AbsSpec

Return the underlying reduced scheme defining ``X``.

This is used to forward the `AbsSpec` functionality to ``X``, but may
trigger the computation of a radical ideal. Hence this can be expensive.
"""
function underlying_scheme(X::AffineAlgebraicSet)
  if isdefined(X, :Xred)
    return X.Xred
  end
  X.Xred = reduced_scheme(X.X)[1]
  return X.Xred
end

function underlying_scheme(X::AffineAlgebraicSet{<:Field,<:MPolyQuoRing})
  if isdefined(X, :Xred)
    return X.Xred
  end
  # avoid constructing a morphism
  I = ambient_closure_ideal(fat_scheme(X))
  Irad = radical(I)
  X.Xred = Spec(base_ring(Irad), Irad)
  return X.Xred
end

########################################################################
#
# (2) AbsAffineAlgebraicSet interface
#
########################################################################
@doc raw"""
    fat_scheme(X::AffineAlgebraicSet) -> AbsSpec

Return a scheme whose reduced subscheme is ``X``.

This does not trigger any computation and is therefore cheap.
Use this instead of `underlying_scheme` when possible.
"""
function fat_scheme(X::AffineAlgebraicSet)
  return X.X
end

########################################################################
#
# (3) Further attributes
#
########################################################################

@doc raw"""
    vanishing_ideal(X::AbsAffineAlgebraicSet) -> Ideal

Return the radical ideal of all polynomials vanishing in ``X``.

!!! note
    This involves the computation of a radical which is expensive.
"""
vanishing_ideal(X::AbsAffineAlgebraicSet) = ambient_closure_ideal(X)

@doc raw"""
    fat_ideal(X::AbsAffineAlgebraicSet) -> Ideal

Return an ideal whose radical is the vanishing ideal of `X`.

If `X` is constructed from an ideal `I` this returns `I`.

```jldoctest
julia> A2 = affine_space(QQ, [:x,:y]);

julia> (x, y) = coordinates(A2);

julia> I = ideal(x^2, y);

julia> X = algebraic_set(I);

julia> fat_ideal(X) === I
true
```
"""
fat_ideal(X::AbsAffineAlgebraicSet) = ambient_closure_ideal(fat_scheme(X))

# avoid computing the underlying scheme
ambient_space(X::AbsAffineAlgebraicSet) = ambient_space(fat_scheme(X))

ambient_space(X::AbsAffineAlgebraicSet{S,T}) where {S<:Field, T<:MPolyRing} = X


