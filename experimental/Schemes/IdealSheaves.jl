export IdealSheaf

export scheme, covering, subscheme, covered_patches, extend!, ideal_dict

export ideal_sheaf_type

### Forwarding the presheaf functionality
underlying_presheaf(I::IdealSheaf) = I.I

@Markdown.doc """
    IdealSheaf(X::ProjectiveScheme, g::Vector{<:RingElem})

Create the ideal sheaf on the covered scheme of ``X`` which is 
generated by the dehomogenization of the homogeneous elements in `g` 
in every chart.
"""
function IdealSheaf(X::ProjectiveScheme, I::MPolyIdeal) 
  S = base_ring(I)
  S === ambient_coordinate_ring(X) || error("ideal does not live in the ambient coordinate ring of the scheme")
  g = gens(I)
  X_covered = covered_scheme(X)
  C = default_covering(X_covered)
  r = fiber_dimension(X)
  I = IdDict{AbsSpec, Ideal}()
  for i in 0:r
    I[C[i+1]] = ideal(OO(C[i+1]), dehomogenize(X, i).(g))
  end
  return IdealSheaf(X_covered, I, check=true)
end

function IdealSheaf(
    X::ProjectiveScheme, 
    g::MPolyElem_dec
  )
  return IdealSheaf(X, [g])
end

function IdealSheaf(
    X::ProjectiveScheme, 
    g::Vector{RingElemType}
  ) where {RingElemType<:MPolyElem_dec}
  X_covered = covered_scheme(X)
  r = fiber_dimension(X)
  I = IdDict{AbsSpec, Ideal}()
  U = basic_patches(default_covering(X_covered))
  for i in 1:length(U)
    I[U[i]] = ideal(OO(U[i]), dehomogenize(X, i-1).(g))
  end
  return IdealSheaf(X_covered, I, check=false)
end

# this constructs the zero ideal sheaf
function IdealSheaf(X::CoveredScheme) 
  C = default_covering(X)
  I = IdDict{AbsSpec, Ideal}()
  for U in basic_patches(C)
    I[U] = ideal(OO(U), elem_type(OO(U))[])
  end
  return IdealSheaf(X, I, check=false)
end

# set up an ideal sheaf by automatic extension 
# from one prescribed set of generators on one affine patch
@Markdown.doc """
    IdealSheaf(X::CoveredScheme, U::AbsSpec, g::Vector)

Set up an ideal sheaf on ``X`` by specifying a set of generators ``g`` 
on one affine open subset ``U`` among the `basic_patches` of the 
`default_covering` of ``X``. 

**Note:** The set ``U`` has to be dense in its connected component 
of ``X`` since otherwise, the extension of the ideal sheaf to other 
charts can not be inferred. 
"""
function IdealSheaf(X::CoveredScheme, U::AbsSpec, g::Vector{RET}) where {RET<:RingElem}
  C = default_covering(X)
  U in patches(C) || error("the affine open patch does not belong to the covering")
  for f in g
    parent(f) === OO(U) || error("the generators do not belong to the correct ring")
  end
  D = IdDict{AbsSpec, Ideal}()
  D[U] = ideal(OO(U), g)
  D = extend!(C, D)
  I = IdealSheaf(X, D, check=false)
  return I
end

# pullback of an ideal sheaf for internal use between coverings of the same scheme
#function (F::CoveringMorphism)(I::IdealSheaf)
#  X = scheme(I)
#  D = codomain(F)
#  D == covering(I) || error("ideal sheaf is not defined on the correct covering")
#  C = domain(F)
#  new_dict = Dict{AbsSpec, Ideal}()
#
#  # go through the patches of C and pull back the generators 
#  # whenever they are defined on the target patch
#  for U in patches(C)
#    f = F[U]
#    V = codomain(f)
#    # for the basic patches here
#    if haskey(ideal_dict(I), V)
#      new_dict[U] = ideal(OO(U), pullback(f).(I[V]))
#    end
#    # check for affine refinements
#    if haskey(affine_refinements(D), V)
#      Vrefs = affine_refinements(D)[V]
#      # pull back the refinement
#      for W in Vrefs
#        h = pullback(f).(gens(W))
#        # take care to discard possibly empty preimages of patches
#        j = [i for i in 1:length(h) if !iszero(h)]
#        Wpre = SpecOpen(U, h[j])
#        add_affine_refinement!(C, Wpre)
#        for i in 1:length(j)
#          if haskey(ideal_dict(I), Wpre[i])
#            new_dict[Wpre[i]] = lifted_numerator.(pullback(f).(I[V[j[i]]]))
#          end
#        end
#      end
#    end
#  end
#  return IdealSheaf(X, C, new_dict)
#end

function +(I::IdealSheaf, J::IdealSheaf) 
  X = space(I)
  X == space(J) || error("ideal sheaves are not defined over the same scheme")
  new_dict = IdDict{AbsSpec, Ideal}()
  CI = default_covering(X)
  for U in patches(CI)
    new_dict[U] = I(U) + J(U)
  end
  return IdealSheaf(X, new_dict, check=false)
end

function *(I::IdealSheaf, J::IdealSheaf) 
  X = space(I)
  X == space(J) || error("ideal sheaves are not defined over the same scheme")
  new_dict = IdDict{AbsSpec, Ideal}()
  CI = default_covering(X)
  for U in patches(CI)
    new_dict[U] = I(U) * J(U)
  end
  return IdealSheaf(X, new_dict, check=false)
end

@Markdown.doc """
    simplify!(I::IdealSheaf)

Replaces the set of generators of the ideal sheaf by a minimal 
set of random linear combinations in every affine patch. 
"""
function simplify!(I::IdealSheaf)
  for U in basic_patches(default_covering(space(I)))
    n = ngens(I(U)) 
    n == 0 && continue
    R = ambient_coordinate_ring(U)
    kk = coefficient_ring(R)
    new_gens = elem_type(OO(U))[]
    K = ideal(OO(U), new_gens) 
    while !issubset(I(U), K)
      new_gen = dot([rand(kk, 1:100) for i in 1:n], gens(I(U)))
      while new_gen in K
        new_gen = dot([rand(kk, 1:100) for i in 1:n], gens(I(U)))
      end
      push!(new_gens, new_gen)
      K = ideal(OO(U), new_gens)
    end
    Oscar.object_cache(underlying_presheaf(I))[U] = K 
  end
  return I
end

@Markdown.doc """
    subscheme(I::IdealSheaf) 

For an ideal sheaf ``ℐ`` on an `AbsCoveredScheme` ``X`` this returns 
the subscheme ``Y ⊂ X`` given by the zero locus of ``ℐ``.
"""
function subscheme(I::IdealSheaf) 
  X = space(I)
  C = default_covering(X)
  new_patches = [subscheme(U, I(U)) for U in basic_patches(C)]
  new_glueings = IdDict{Tuple{AbsSpec, AbsSpec}, AbsGlueing}()
  for (U, V) in keys(glueings(C))
    i = C[U]
    j = C[V]
    Unew = new_patches[i]
    Vnew = new_patches[j]
    G = C[U, V]
    new_glueings[(Unew, Vnew)] = restrict(C[U, V], Unew, Vnew, check=false)
    new_glueings[(Vnew, Unew)] = inverse(new_glueings[(Unew, Vnew)])
  end
  Cnew = Covering(new_patches, new_glueings, check=false)
  return CoveredScheme(Cnew)
end


@Markdown.doc """
    extend!(C::Covering, D::Dict{SpecType, IdealType}) where {SpecType<:Spec, IdealType<:Ideal}

For ``C`` a covering and ``D`` a dictionary holding vectors of 
polynomials on affine patches of ``C`` this function extends the 
collection of polynomials over all patches in a compatible way; 
meaning that on the overlaps the restrictions of either two sets 
of polynomials coincides.

This proceeds by crawling through the glueing graph and taking 
closures in the patches ``Uⱼ`` of the subschemes 
``Zᵢⱼ = V(I) ∩ Uᵢ ∩ Uⱼ`` in the intersection with a patch ``Uᵢ`` 
on which ``I`` had already been described.

Note that the covering `C` is not modified.  
"""
function extend!(
    C::Covering, D::IdDict{AbsSpec, Ideal}
  )
  gg = glueing_graph(C)
  # push all nodes on which I is known in a heap
  dirty_patches = collect(keys(D))
  while length(dirty_patches) > 0
    U = pop!(dirty_patches)
    N = neighbor_patches(C, U)
    Z = subscheme(U, D[U])
    for V in N
      # check whether this node already knows about D
      haskey(D, V)  && continue

      # if not, extend D to this patch
      f, _ = glueing_morphisms(C[V, U])
      pZ = preimage(f, Z)
      ZV = closure(pZ, V)
      D[V] = ideal(OO(V), gens(saturated_ideal(modulus(OO(ZV)))))
      V in dirty_patches || push!(dirty_patches, V)
    end
  end
  for U in basic_patches(C) 
    if !haskey(D, U)
      D[U] = ideal(OO(U), zero(OO(U)))
    end
  end
  return D
end

function Base.show(io::IO, I::IdealSheaf)
  print(io, "sheaf of ideals on $(space(I))")
end

function ==(I::IdealSheaf, J::IdealSheaf)
  X = space(I)
  X == space(J) || return false
  for U in basic_patches(default_covering(X))
    is_subset(I(U), J(U)) && is_subset(J(U), I(U)) || return false
  end
  return true
end

function is_subset(I::IdealSheaf, J::IdealSheaf)
  X = space(I)
  X == space(J) || return false
  for U in basic_patches(default_covering(X))
    is_subset(I(U), J(U)) || return false
  end
  return true
end

# prepares a refinement C' of the covering for the ideal sheaf I 
# such that I can be generated by a regular sequence defining a smooth 
# local complete intersection subscheme in every patch U of C' and 
# returns the ideal sheaf with those generators on C'.
#function as_smooth_lci(
#    I::IdealSheaf;
#    verbose::Bool=false,
#    check::Bool=true,
#    codimension::Int=dim(scheme(I))-dim(subscheme(I)) #assumes both scheme(I) and its subscheme to be equidimensional
#  )
#  X = scheme(I)
#  C = covering(I)
#  SpecType = affine_patch_type(C)
#  PolyType = poly_type(SpecType)
#  new_gens_dict = Dict{SpecType, Vector{PolyType}}()
#  for U in patches(C)
#    V, spec_dict = as_smooth_lci(U, I[U], 
#                                 verbose=verbose, 
#                                 check=check, 
#                                 codimension=codimension) 
#    add_affine_refinement!(C, V)
#    merge!(new_gens_dict, spec_dict)
#  end
#  Iprep = IdealSheaf(X, C, new_gens_dict)
#  set_attribute!(Iprep, :is_regular_sequence, true)
#  return Iprep
#end
#
#function as_smooth_lci(
#    U::Spec, g::Vector{T}; 
#    verbose::Bool=false,
#    check::Bool=true,
#    codimension::Int=dim(U)-dim(subscheme(U, g)) # this assumes both U and its subscheme to be equidimensional
#  ) where {T<:MPolyElem}
#  verbose && println("preparing $g as a local complete intersection on $U")
#  f = numerator.(gens(localized_modulus(OO(U))))
#  f = [a for a in f if !iszero(a)]
#  verbose && println("found $(length(f)) generators for the ideal defining U")
#  h = vcat(f, g)
#  r = length(f)
#  s = length(g)
#  Dh = jacobi_matrix(h)
#  (ll, ql, rl, cl) = _non_degeneration_cover(subscheme(U, g), Dh, codimension + codim(U), 
#                          verbose=verbose, check=check, 
#                          restricted_columns=[collect(1:r), [r + k for k in 1:s]])
#
#  n = length(ll)
#  # first process the necessary refinements of U
#  # The restricted columns in the call to _non_degenerate_cover 
#  # assure that the first codim(U) entries of every cl[i] are 
#  # indices of some element of f. However, we can discard these, 
#  # as they are trivial generators of the ideal sheaf on U.
#  minor_list = [det(Dh[rl[i], cl[i]]) for i in 1:n]
#  V = Vector{open_subset_type(U)}()
#  SpecType = typeof(U)
#  PolyType = poly_type(U)
#  spec_dict = Dict{SpecType, Vector{PolyType}}()
#  g = Vector{PolyType}()
#  W = SpecOpen(U, minor_list)
#  for i in 1:n
#    spec_dict[W[i]] = h[cl[i][codim(U)+1:end]]
#  end
#  return W, spec_dict
#end
#

function is_prime(I::IdealSheaf) 
  return all(U->is_prime(I(U)), basic_patches(default_covering(space(I))))
end

