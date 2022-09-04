


@testset "walls of chamber" begin
  S = Zlattice(gram=QQ[-2 1 0 0; 1 -2 1 1; 0 1 -2 1; 0 1 1 -2])
  # fix an embedding
  B = matrix(FlintQQ, 10, 10 ,[1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1//3, 2//3, 1//3, 2//3, 2//3, 2//3, 1//3, 1//3, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1]);
  G = matrix(FlintQQ, 10, 10 ,[-2, 1, 0, 0, 0, 0, 0, 0, 0, 0, 1, -2, 1, 1, 0, 0, 0, 0, 0, 0, 0, 1, -2, 1, 0, 0, 0, 0, 0, 0, 0, 1, 1, -2, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, -2, -1, 1, -1, -1, -1, 0, 0, 0, 0, -1, -2, 1, -1, 0, -1, 0, 0, 0, 0, 1, 1, -2, 0, 0, 1, 0, 0, 0, 0, -1, -1, 0, -2, -1, -1, 0, 0, 0, 0, -1, 0, 0, -1, -2, -1, 0, 0, 0, 0, -1, -1, 1, -1, -1, -2]);
  L = Zlattice(B, gram = G);

  B = matrix(FlintQQ, 4, 10 ,[1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0]);
  G = matrix(FlintQQ, 10, 10 ,[-2, 1, 0, 0, 0, 0, 0, 0, 0, 0, 1, -2, 1, 1, 0, 0, 0, 0, 0, 0, 0, 1, -2, 1, 0, 0, 0, 0, 0, 0, 0, 1, 1, -2, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, -2, -1, 1, -1, -1, -1, 0, 0, 0, 0, -1, -2, 1, -1, 0, -1, 0, 0, 0, 0, 1, 1, -2, 0, 0, 1, 0, 0, 0, 0, -1, -1, 0, -2, -1, -1, 0, 0, 0, 0, -1, 0, 0, -1, -2, -1, 0, 0, 0, 0, -1, -1, 1, -1, -1, -2]);
  S = Zlattice(B, gram = G);

  weyl = QQ[31   61   52   71   5   -6   5   -2   -7   8]
  k3 = Oscar.BorcherdsData(L, S, false)
  weylk3 = change_base_ring(ZZ,solve_left(basis_matrix(L), weyl))
  walls = oscar._walls_of_chamber(k3, weylk3)
  @test length(walls)==4
  walls1 =  [
  ZZ[0   0   2   1],
  ZZ[1   1   1   2],
  ZZ[0   0   -1   -1],
  ZZ[-1   0   0   0]]
  @test issetequal(walls, walls1)
end

@testset "K3 surface automorphism groups" begin
  S = Zlattice(gram=QQ[-2 1 0 0; 1 -2 1 1; 0 1 -2 1; 0 1 1 -2])
  k3aut, chambers, rational_mod_aut = K3Auto(S, 10, compute_OR=true)
  @test order(matrix_group(k3aut))==2
  @test length(chambers) == 1
  @test length(rational_mod_aut) == 3

  k3aut, chambers, rational_mod_aut = K3Auto(S, 18, compute_OR=true)
  @test order(matrix_group(k3aut))==2
  @test length(chambers) == 1
  @test length(rational_mod_aut) == 3

  k3aut, chambers, rational_mod_aut = K3Auto(S, 26, compute_OR=true)
  @test order(matrix_group(k3aut))==2
  @test length(chambers) == 1
  @test length(rational_mod_aut) == 3

  # Another example with finite automorphism group
  S,_,_=orthogonal_sum(Zlattice(gram=ZZ[0 1; 1 -2]),rescale(root_lattice(:D,4),-1))
  k3aut, chambers, rational_mod_aut = K3Auto(S, 10, compute_OR=true)
  @test order(matrix_group(k3aut))==6
  @test length(chambers) == 1
  @test length(rational_mod_aut) == 4

  k3aut, chambers, rational_mod_aut = K3Auto(S, 18, compute_OR=true)
  @test order(matrix_group(k3aut))==6
  @test length(chambers) == 1
  @test length(rational_mod_aut) == 4

  k3aut, chambers, rational_mod_aut = K3Auto(S, 26, compute_OR=true)
  @test order(matrix_group(k3aut))==6
  @test length(chambers) == 1
  @test length(rational_mod_aut) == 4

  S,_,_=orthogonal_sum(Zlattice(gram=ZZ[0 1; 1 -2]),rescale(root_lattice(:D,4),-1))
  k3aut, chambers, rational_mod_aut = K3Auto(S, 10, compute_OR=false)
  @test length(k3aut)==0
  @test length(chambers) == 6
  @test length(rational_mod_aut) == 6


  # one with parabolic automorphism group
  S,iU,_=orthogonal_sum(Zlattice(gram=ZZ[0 1; 1 -2]),Zlattice(gram=ZZ[-50;]))
  k3aut, chambers, rational_mod_aut = K3Auto(S, 10, compute_OR=true)
  @test length(k3aut)==2
  @test length(chambers) == 74
  @test length(rational_mod_aut) == 4

  C = lattice(ambient_space(S),common_invariant(k3aut)[2])
  d = diagonal(rational_span(C))
  @test d[1] == 0 # a common invariant isotropic ray.


  S,iU,_=orthogonal_sum(Zlattice(gram=ZZ[0 1; 1 -2]),Zlattice(gram=ZZ[-50;]))
  k3aut, chambers, rational_mod_aut = K3Auto(S, 10, compute_OR=false)
  @test length(k3aut)==2
  @test length(chambers) == 74
  @test length(rational_mod_aut) == 4

end

