export vanishing_ideal

########################################################################
#
# (1) AbsProjectiveScheme interface
#
########################################################################

underlying_scheme(X::ProjectiveAlgebraicSet) = X.X

@doc Markdown.doc"""
    vanishing_ideal(X::AbsProjectiveAlgebraicSet) -> Ideal

Return the ideal of all homogeneous polynomials vanishing in ``X``.
"""
vanishing_ideal(X::AbsProjectiveAlgebraicSet) = defining_ideal(X)


@doc Markdown.doc"""
    ideal(X::AbsProjectiveAlgebraicSet) -> Ideal

Return the ideal of all homogeneous polynomials vanishing in ``X``.
"""
ideal(X::AbsProjectiveAlgebraicSet) = vanishing_ideal(X)
