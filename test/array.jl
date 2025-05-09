using Enzyme, Test

function ptrcopy(B, A)
@static if VERSION < v"1.11"
	Base.unsafe_copyto!(B, 1, A, 1, 2)
else
	Base.unsafe_copyto!(B.ref, A.ref, 2)
end
	nothing
end

@testset "Array of Pointer Copy" begin
	A = [[2.7, 3.1], [4.7, 5.6]]
	dA1 = [1.1, 4.3]
	dA2 = [17.2, 0.26]
	dA = [dA1, dA2]

	B = [[2.0, 4.0], [7.0, 11.0]]
	dB = Enzyme.make_zero(B)

	Enzyme.autodiff(set_runtime_activity(Reverse), ptrcopy, Duplicated(B, dB), Duplicated(A, dA))

	@test dB[1] === dA1
	@test dB[2] === dA2
end

function unsafe_wrap_test(a, i, x)
	GC.@preserve a begin
		 ptr = pointer(a)
		 b = Base.unsafe_wrap(Array, ptr, length(a))
		 b[i] = x
	end
	a[i]
end

@testset "Unsafe wrap" begin
   autodiff(Forward, unsafe_wrap_test,  Duplicated(zeros(1), zeros(1)), Const(1), Duplicated(1.0, 2.0))

	# TODO test for batch and reverse
end
