######################
# 4: Properties
######################

@doc Markdown.doc"""
    isnormal(v::AbstractNormalToricVariety)

Checks if the normal toric variety `v` is normal. (This function is somewhat tautological at this point.)

# Examples
```jldoctest
julia> isnormal(toric_projective_space(2))
true
```
"""
function isnormal(v::AbstractNormalToricVariety)
    return true
end
export isnormal


@doc Markdown.doc"""
    isaffine(v::AbstractNormalToricVariety)

Checks if the normal toric variety `v` is affine.

# Examples
```jldoctest
julia> isaffine(toric_projective_space(2))
false
```
"""
function isaffine(v::AbstractNormalToricVariety)
    return pm_object(v).AFFINE::Bool
end
export isaffine


@doc Markdown.doc"""
    isprojective(v::AbstractNormalToricVariety)

Checks if the normal toric variety `v` is projective, i.e. if the fan of `v` is the the normal fan of a polytope.

# Examples
```jldoctest
julia> isprojective(toric_projective_space(2))
true
```
"""
function isprojective(v::AbstractNormalToricVariety)
    return pm_object(v).PROJECTIVE::Bool
end
export isprojective


@doc Markdown.doc"""
    isprojective_space(v::AbstractNormalToricVariety)

Decides if the normal toric varieties `v` is a projective space.

# Examples
```jldoctest
julia> H5 = hirzebruch_surface(5)
A normal toric variety corresponding to a polyhedral fan in ambient dimension 2

julia> isprojective_space(H5)
false

julia> isprojective_space(toric_projective_space(2))
true
```
"""
function isprojective_space(v::AbstractNormalToricVariety)
    if issmooth(v) == false
        return false
    end
    if isprojective(v) == false
        return false
    end
    if rank(class_group(v)) > 1
        return false
    end
    w = [[Int(x) for x in transpose(g.coeff)] for g in gens(class_group(v))]
    for g in gens(class_group(v))
        g = [Int(x) for x in g.coeff if !iszero(x)]    
        if length(g) > 1
            return false
        end
        if g[1] != 1
            return false
        end
    end
    return irrelevant_ideal(v) == ideal(gens(cox_ring(v)))
end
export isprojective_space


@doc Markdown.doc"""
    issmooth(v::AbstractNormalToricVariety)

Checks if the normal toric variety `v` is smooth.

# Examples
```jldoctest
julia> issmooth(toric_projective_space(2))
true
```
"""
function issmooth(v::AbstractNormalToricVariety)
    return pm_object(v).SMOOTH::Bool
end
export issmooth


@doc Markdown.doc"""
    iscomplete(v::AbstractNormalToricVariety)

Checks if the normal toric variety `v` is complete.

# Examples
```jldoctest
julia> iscomplete(toric_projective_space(2))
true
```
"""
function iscomplete(v::AbstractNormalToricVariety)
    return pm_object(v).COMPLETE::Bool
end
export iscomplete


@doc Markdown.doc"""
    hastorusfactor(v::AbstractNormalToricVariety)

Checks if the normal toric variety `v` has a torus factor.

# Examples
```jldoctest
julia> hastorusfactor(toric_projective_space(2))
false
```
"""
function hastorusfactor(v::AbstractNormalToricVariety)
    return pm_object(v).FAN_DIM < pm_object(v).FAN_AMBIENT_DIM
end
export hastorusfactor


@doc Markdown.doc"""
    isorbifold(v::AbstractNormalToricVariety)

Checks if the normal toric variety `v` is an orbifold.

# Examples
```jldoctest
julia> isorbifold(toric_projective_space(2))
true
```
"""
function isorbifold(v::AbstractNormalToricVariety)
    return pm_object(v).SIMPLICIAL::Bool
end
export isorbifold


@doc Markdown.doc"""
    issimplicial(v::AbstractNormalToricVariety)

Checks if the normal toric variety `v` is simplicial. Hence, this function works just as `isorbifold`. It is implemented for user convenience.

# Examples
```jldoctest
julia> issimplicial(toric_projective_space(2))
true
```
"""
function issimplicial(v::AbstractNormalToricVariety)
    return pm_object(v).SIMPLICIAL::Bool
end
export issimplicial


@doc Markdown.doc"""
    isgorenstein(v::AbstractNormalToricVariety)

Checks if the normal toric variety `v` is Gorenstein.

# Examples
```jldoctest
julia> isgorenstein(toric_projective_space(2))
true
```
"""
function isgorenstein(v::AbstractNormalToricVariety)
    return pm_object(v).GORENSTEIN::Bool
end
export isgorenstein


@doc Markdown.doc"""
    isq_gorenstein(v::AbstractNormalToricVariety)

Checks if the normal toric variety `v` is Q-Gorenstein.

# Examples
```jldoctest
julia> isq_gorenstein(toric_projective_space(2))
true
```
"""
function isq_gorenstein(v::AbstractNormalToricVariety)
    return pm_object(v).Q_GORENSTEIN::Bool
end
export isq_gorenstein


@doc Markdown.doc"""
    isfano(v::AbstractNormalToricVariety)

Checks if the normal toric variety `v` is fano.

# Examples
```jldoctest
julia> isfano(toric_projective_space(2))
true
```
"""
function isfano(v::AbstractNormalToricVariety)
    return pm_object(v).FANO::Bool
end
export isfano
