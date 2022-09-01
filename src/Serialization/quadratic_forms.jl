@registerSerializationType(Chamber)
function save_internal(s::SerializerState, D::Chamber)
    return Dict(
        :BorcherdsData => save_type_dispatch(s, D.data),
        :weyl_vector => save_type_dispatch(s, D.weyl_vector),
        :walls => save_type_dispatch(s, D.walls),
        :parent_wall => save_type_dispatch(s, D.parent_wall)
    )
end

function load_internal(s::DeserializerState, ::Type{Chamber}, dict::Dict)
    weyl_vector = load_type_dispatch(s, fmpz_mat, dict[:weyl_vector])
    walls = load_type_dispatch(s, Vector{fmpz_mat}, dict[:walls])
    parent_wall = load_type_dispatch(s, fmpz_mat, dict[:parent_wall])
    data = load_type_dispatch(s, BorcherdsData, dict[:BorcherdsData])
    return Chamber(data, weyl_vector, parent_wall, walls)
end


@registerSerializationType(BorcherdsData)
function save_internal(s::SerializerState, D::BorcherdsData)
    return Dict(
        :L => save_type_dispatch(s, D.L),
        :S => save_type_dispatch(s, D.S),
        :compute_OR => save_type_dispatch(s, D.compute_OR), #needs to be worked out
    )
end

function load_internal(s::DeserializerState, ::Type{BorcherdsData}, dict::Dict)
    L = load_type_dispatch(s, ZLat, dict[:L])
    S = load_type_dispatch(s, ZLat, dict[:S])
    compute_OR = load_type_dispatch(s, Bool, dict[:compute_OR])

    return BorcherdsData(L, S, compute_OR)
end



#encodeType(::Type{Hecke.QuadSpace{S,T}}) where {S = "Hecke.QuadSpace{$S,$T}"}
#reverseTypeMap["Hecke.QuadSpace{S,T}"] = Hecke.QuadSpace{S,T}

@registerSerializationType(ZLat)
@registerSerializationType(Hecke.QuadSpace{FlintRationalField,fmpq_mat} where {S,T})

function save_internal(s::SerializerState, V::Hecke.QuadSpace)
    return Dict(
        :base_ring => save_type_dispatch(s, base_ring(V)),
        :gram_matrix => save_type_dispatch(s, gram_matrix(V))
    )
end


function load_internal(s::DeserializerState, ::Type{Hecke.QuadSpace{S,T}}, dict::Dict) where {S,T}
    F = load_type_dispatch(s, S, dict[:base_ring])
    gram = load_type_dispatch(s, T, dict[:gram_matrix])
    @assert base_ring(gram)===F
    return quadratic_space(F, gram)
end



function save_internal(s::SerializerState, L::ZLat)
    return Dict(
        :basis => save_type_dispatch(s, basis_matrix(L)),
        :ambient_space => save_type_dispatch(s, ambient_space(L))
    )
end

function load_internal(s::DeserializerState, ::Type{ZLat}, dict::Dict)
    B = load_type_dispatch(s, fmpq_mat, dict[:basis])
    V = load_type_dispatch(s, Hecke.QuadSpace{FlintRationalField, fmpq_mat}, dict[:ambient_space])
    return lattice(V, B)
end
