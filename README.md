# Money

A mini library to work with monetary values. Built with correctness in mind.

Monetary values are represented as [FixedPointDecimals](https://github.com/JuliaMath/FixedPointDecimals.jl) and a given currency symbol.

```julia
using Test
using Money

EUR_10_57 = Monetary(:EUR, "10.57") # EUR 10.570000000000000000

using Money: M

@test EUR_10_57 + 10 == M(:EUR, "20.57")
@test EUR_10_57 + "10.01" == M(:EUR, "20.58")
```

Avoid unintentional mixup of non fixed-point `Real` values with `Monetary` values:
```julia
using Test
using Money

@test_throws InexactError convert(Monetary{:EUR, 2}, 20.33)

using Printf
using Money: M

@test M(:EUR, @sprintf "%.2f"  20.33) == M(:EUR, "20.330000000000000000")
@test M(:EUR, @sprintf "%.14f" 20.33) == M(:EUR, "20.330000000000000000")
@test M(:EUR, @sprintf "%.15f" 20.33) == M(:EUR, "20.329999999999998000")
@test M(:EUR, @sprintf "%.18f" 20.33) == M(:EUR, "20.329999999999998295")
```

Avoid unintentional mixup of different currencies:
```julia
using Test
using Money: M

@test_throws ErrorException M(:EUR, "10.00") + M(:USD, "10.00")
```

Made to play with `DataFrames.jl` and `Query.jl`:
```julia
using Dates
using CSV
using DataFrames
using Missings
using Query
using Money: M

file = "transactions.csv"
raw = CSV.File(file;
   types=Dict(
      :Date     => Union{Missing,DateTime},
      :Currency => Union{Missing,Symbol},
      :Amount   => Union{Missing,String},
   dateformat="yyyy-mm-dd HH:MM:SS") |> DataFrame

transactions = @from i in raw begin
    @select {date=i.Date, amount=M(get(i.Currency), get(i.Amount))}
    @collect DataFrame
end
```
```
8×2 DataFrame
│ Row │ date                │ amount            │
│     │ DateTime            │ Monetary…         │
├─────┼─────────────────────┼───────────────────┤
│ 1   │ 2008-08-20T09:49:01 │ EUR 0.68168320713 │
│ 2   │ 2009-07-21T17:16:20 │ EUR 1.55012697096 │
│ 3   │ 2010-06-22T14:04:30 │ USD 2.52834844951 │
│ 4   │ 2011-05-23T22:38:45 │ USD 3.37435318872 │
...
```
