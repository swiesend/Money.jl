using Test
using Klar.Money: Monetary, M,
                  AssetMismatch,
                  convert,
                  decimals, name

@test convert(Monetary{:EUR,18}, 10) == M(:EUR, "10")
@test convert(Monetary{:USD,18}, 10) == M(:USD, "10")
@test convert(Monetary{:EUR,18}, M(:USD,10).amount) == M(:EUR, 10)
@test_throws InexactError convert(Monetary{:EUR,18}, 10.01)

@test promote_type(Monetary{:EUR,1},Monetary{:EUR,18}) == Monetary{:EUR,18}
@test promote_type(Monetary{:EUR,18},Monetary{:EUR,1}) == Monetary{:EUR,18}
@test promote_type(Monetary{:EUR,18},String) == Monetary{:EUR,18}
@test promote_type(Monetary{:EUR,18},Integer) == Monetary{:EUR,18}

@test promote_type(Monetary{:EUR,10},Monetary{:USD,18}) == Monetary{name,18} where name

@test_throws InexactError promote_type(Monetary{:EUR,18},Real)
@test_throws InexactError promote_type(Monetary{:EUR,18},AbstractFloat)
@test_throws InexactError promote_type(Monetary{:EUR,18},Float32)
@test_throws InexactError promote_type(Monetary{:EUR,18},Float64)
@test_throws InexactError promote_type(Monetary{:EUR,18},BigFloat)

@test promote(M(:EUR, 10), 20) == (M(:EUR, 10), M(:EUR, 20))
@test promote(M(:EUR, 10), "20.02") == (M(:EUR, 10), M(:EUR, "20.02"))
@test_throws ErrorException promote(M(:EUR, 10), M(:USD, 10))
@test_throws InexactError promote(M(:EUR, 10), 20.33)
@test_throws InexactError promote(M(:EUR, 10), BigFloat(20.33))

EUR_10_57 = M(:EUR, "10.57")
EUR_0_533 = M(:EUR, "0.533")
USD_N_0_533 = M(:USD, "-0.533")
# USD_10 = M(:USD, 10)
# USD_10_33 = M(:USD, "10.33")

@test decimals(EUR_10_57) == 18
@test name(EUR_10_57) == :EUR

@test EUR_10_57 + "10.01" == M(:EUR, "20.58")
@test EUR_10_57 + 10 == M(:EUR, "20.57")

@test_throws InexactError EUR_10_57 + 10.01
@test_throws InexactError 10.01 + EUR_10_57
@test_throws InexactError EUR_10_57 - 10.01
@test_throws InexactError 10.01 - EUR_10_57
@test_throws InexactError EUR_10_57 * 10.01
@test_throws InexactError 10.01 * EUR_10_57
@test_throws InexactError EUR_10_57 / 10.01
@test_throws InexactError 10.01 / EUR_10_57

@test_throws ErrorException EUR_10_57 + USD_N_0_533
@test_throws ErrorException USD_N_0_533 <= EUR_10_57

@test_throws ArgumentError EUR_10_57 + "abc"

# unary operators
@test abs(USD_N_0_533).amount == EUR_0_533.amount
@test sign(EUR_0_533) == 1
@test sign(USD_N_0_533) == -1

@test round(M(:EUR, "0.40")) == M(:EUR, "0.0")
@test round(M(:EUR, "0.50")) == M(:EUR, "0.0")
@test round(M(:EUR, "0.500000000000000001")) == M(:EUR, "1.0")  # 18 decimals
@test round(M(:EUR, "0.5000000000000000001")) == M(:EUR, "0.0") # 19 decimals
@test trunc(M(:EUR, "0.6")) == M(:EUR, "0.0")
@test floor(M(:EUR, "0.6")) == M(:EUR, "0.0")
@test ceil(M(:EUR, "0.6")) == M(:EUR, "1.0")

@test isapprox(M(:EUR, 5), M(:EUR, "5.0")) == true
@test isapprox(M(:EUR, 5), M(:EUR, "5.1")) == false
@test isapprox(M(:EUR, 5), M(:EUR, "5.000000000000000001")) == false
@test isapprox(M(:EUR, 5), M(:EUR, "5.0000000000000000001")) == true

# binary operators
@test EUR_10_57 + EUR_0_533 == M(:EUR, "11.103")
@test EUR_10_57 - EUR_0_533 == M(:EUR, "10.037")
@test EUR_10_57 * M(:EUR, "2.0") == EUR_10_57 + EUR_10_57
@test -1 * EUR_10_57 == M(:EUR, "-10.57")
@test EUR_10_57 * -1 == M(:EUR, "-10.57")
@test "-1" * EUR_10_57 == M(:EUR, "-10.57")
@test EUR_10_57 * "-1" == M(:EUR, "-10.57")
@test (EUR_10_57 / M(:EUR, "0.5")) / M(:EUR, "2.0") == EUR_10_57
@test (USD_N_0_533 / M(:USD, "0.5")) / M(:USD, "2.0") == USD_N_0_533
@test (M(:EUR, "11.103") / M(:EUR, "0.5")) / M(:EUR, "2.0") == M(:EUR, "11.103")

@test EUR_10_57 == EUR_10_57
@test !(EUR_10_57 == EUR_0_533)
@test EUR_10_57 != EUR_0_533
@test EUR_10_57 > EUR_0_533
@test EUR_0_533 < EUR_10_57
@test EUR_0_533 <= EUR_10_57
@test EUR_0_533 <= EUR_0_533

@test min(EUR_10_57, EUR_0_533) == EUR_0_533
@test max(EUR_10_57, EUR_0_533) == EUR_10_57
@test minmax(EUR_10_57, EUR_0_533) == (EUR_0_533, EUR_10_57)

@test div(M(:EUR, "9"), M(:EUR, "5")) == M(:EUR, "1.0")
@test div(M(:EUR, "10"), M(:EUR, "5")) == M(:EUR, "2.0")
@test div(M(:EUR, "11"), M(:EUR, "5")) == M(:EUR, "2.0")
@test rem(M(:EUR, "7"), M(:EUR, "5")) == M(:EUR, "2.0")
@test rem(M(:EUR, "10"), M(:EUR, "5")) == M(:EUR, "0.0")
@test rem(M(:EUR, "12"), M(:EUR, "5")) == M(:EUR, "2.0")
@test divrem(M(:EUR, "11"), M(:EUR, "5")) == (M(:EUR, "2.0"),M(:EUR, "1.0"))

@test flipsign(M(:EUR, 5),   1)  == M(:EUR,  "5.0")
@test flipsign(M(:EUR, 5),  "1") == M(:EUR,  "5.0")
@test flipsign(M(:EUR, 5),  -1)  == M(:EUR, "-5.0")
@test flipsign(M(:EUR, 5), "-1") == M(:EUR, "-5.0")

# using Printf
# s1 = @sprintf "%.2f" 20.33
# s2 = @sprintf "%.14f" 20.33
# s3 = @sprintf "%.15f" 20.33
# s4 = @sprintf "%.40f" 20.33
# s5 = @sprintf "%.2f"  BigFloat(20.33)
# s6 = @sprintf "%.14f" BigFloat(20.33)
# s7 = @sprintf "%.15f" BigFloat(20.33)
# s8 = @sprintf "%.40f" BigFloat(20.33)
# EUR_20_33_Float64 = M(:EUR, s1)
# EUR_20_33_BigFloat = M(:EUR, s5)
