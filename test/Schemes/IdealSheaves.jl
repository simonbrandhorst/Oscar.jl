IP2 = projective_space(QQ, 2)
X = covered_scheme(IP2)
S = ambient_ring(IP2)
(u,v,w) = gens(S)
I = ideal(S, u^2 - v*w)
IS = IdealSheaf(X, I)
