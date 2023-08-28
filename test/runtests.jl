using AwkwardArray
using Test

@testset "AwkwardArray.jl" begin
    ### PrimitiveArray #######################################################

    begin
        layout = AwkwardArray.PrimitiveArray([1.1, 2.2, 3.3, 4.4, 5.5])
        @test AwkwardArray.is_valid(layout)
        @test length(layout) == 5
        @test layout[2] == 2.2
        @test layout[end] == 5.5
        @test layout[end-1] == 4.4
        @test layout[2:4] == AwkwardArray.PrimitiveArray([2.2, 3.3, 4.4])
        tmp = 0.0
        for x in layout
            @test x < 6
            tmp += x
        end
        @test tmp == 16.5
    end

    begin
        layout = AwkwardArray.PrimitiveArray{Float64}()
        @test length(layout) == 0
        AwkwardArray.push!(layout, 1.1)
        @test length(layout) == 1
        AwkwardArray.push!(layout, 2.2)
        @test length(layout) == 2
        AwkwardArray.push!(layout, 3.3)
        @test length(layout) == 3
        AwkwardArray.push!(layout, 4.4)
        @test length(layout) == 4
        AwkwardArray.push!(layout, 5.5)
        @test length(layout) == 5
        @test layout == AwkwardArray.PrimitiveArray([1.1, 2.2, 3.3, 4.4, 5.5])

        AwkwardArray.push_dummy!(layout)
        @test length(layout) == 6
        @test layout == AwkwardArray.PrimitiveArray([1.1, 2.2, 3.3, 4.4, 5.5, 0.0])
        @test AwkwardArray.is_valid(layout)
    end

    ### EmptyArray ###########################################################

    begin
        layout = AwkwardArray.EmptyArray()
        @test AwkwardArray.is_valid(layout)
        @test length(layout) == 0
        @test layout[100:99] == layout
        tmp = 0.0
        for x in layout
            tmp += x
        end
        @test tmp == 0.0
        @test layout == AwkwardArray.PrimitiveArray(Vector{Float64}())
    end

    begin
        layout = AwkwardArray.EmptyArray()
        @test length(layout) == 0
        @test layout == AwkwardArray.EmptyArray()
    end

    ### ListOffsetArray ######################################################

    begin
        layout = AwkwardArray.ListOffsetArray(
            [0, 3, 3, 5],
            AwkwardArray.PrimitiveArray([1.1, 2.2, 3.3, 4.4, 5.5]),
        )
        @test AwkwardArray.is_valid(layout)
        @test length(layout) == 3
        @test layout[1] == AwkwardArray.PrimitiveArray([1.1, 2.2, 3.3])
        @test layout[end-1] == AwkwardArray.PrimitiveArray([])
        @test layout[end] == AwkwardArray.PrimitiveArray([4.4, 5.5])
        @test layout[1:2] == AwkwardArray.ListOffsetArray(
            [0, 3, 3],
            AwkwardArray.PrimitiveArray([1.1, 2.2, 3.3]),
        )
        tmp = 0
        for x in layout
            @test length(x) <= 3
            tmp += length(x)
        end
        @test tmp == 5
    end

    begin
        layout = AwkwardArray.ListOffsetArray(
            [0, 3, 2, 5],
            AwkwardArray.PrimitiveArray([1.1, 2.2, 3.3, 4.4, 5.5]),
        )
        @test !AwkwardArray.is_valid(layout)
    end

    begin
        layout = AwkwardArray.ListOffsetArray(
            [0, 3, 3, 6],
            AwkwardArray.PrimitiveArray([1.1, 2.2, 3.3, 4.4, 5.5]),
        )
        @test !AwkwardArray.is_valid(layout)
    end

    begin
        layout = AwkwardArray.ListOffsetArray(
            [-1, 3, 3, 5],
            AwkwardArray.PrimitiveArray([1.1, 2.2, 3.3, 4.4, 5.5]),
        )
        @test !AwkwardArray.is_valid(layout)
    end

    begin
        layout = AwkwardArray.ListOffsetArray{
            AwkwardArray.Index64,
            AwkwardArray.PrimitiveArray{Float64},
        }()
        sublayout = layout.content
        @test length(layout) == 0
        AwkwardArray.push!(sublayout, 1.1)
        AwkwardArray.push!(sublayout, 2.2)
        AwkwardArray.push!(sublayout, 3.3)
        AwkwardArray.end_list!(layout)
        @test length(layout) == 1
        AwkwardArray.end_list!(layout)
        @test length(layout) == 2
        AwkwardArray.push!(sublayout, 4.4)
        AwkwardArray.push!(sublayout, 5.5)
        AwkwardArray.end_list!(layout)
        @test length(layout) == 3
        @test layout == AwkwardArray.ListOffsetArray(
            [0, 3, 3, 5],
            AwkwardArray.PrimitiveArray([1.1, 2.2, 3.3, 4.4, 5.5]),
        )

        AwkwardArray.push_dummy!(layout)
        @test length(layout) == 4
        @test layout == AwkwardArray.ListOffsetArray(
            [0, 3, 3, 5, 5],
            AwkwardArray.PrimitiveArray([1.1, 2.2, 3.3, 4.4, 5.5]),
        )
        @test AwkwardArray.is_valid(layout)
    end

    ### ListArray ######################################################

    begin
        layout = AwkwardArray.ListArray(
            [0, 3, 3],
            [3, 3, 5],
            AwkwardArray.PrimitiveArray([1.1, 2.2, 3.3, 4.4, 5.5]),
        )
        @test AwkwardArray.is_valid(layout)
        @test length(layout) == 3
        @test layout[1] == AwkwardArray.PrimitiveArray([1.1, 2.2, 3.3])
        @test layout[end-1] == AwkwardArray.PrimitiveArray([])
        @test layout[end] == AwkwardArray.PrimitiveArray([4.4, 5.5])
        @test layout[1:2] == AwkwardArray.ListArray(
            [0, 3],
            [3, 3],
            AwkwardArray.PrimitiveArray([1.1, 2.2, 3.3]),
        )
        tmp = 0
        for x in layout
            @test length(x) <= 3
            tmp += length(x)
        end
        @test tmp == 5
    end

    begin
        layout = AwkwardArray.ListArray(
            [0, 3, 2],
            [3, 2, 5],
            AwkwardArray.PrimitiveArray([1.1, 2.2, 3.3, 4.4, 5.5]),
        )
        @test !AwkwardArray.is_valid(layout)
    end

    begin
        layout = AwkwardArray.ListArray(
            [0, 3, 3],
            [3, 3, 6],
            AwkwardArray.PrimitiveArray([1.1, 2.2, 3.3, 4.4, 5.5]),
        )
        @test !AwkwardArray.is_valid(layout)
    end

    begin
        layout = AwkwardArray.ListArray(
            [-1, 3, 3],
            [3, 3, 5],
            AwkwardArray.PrimitiveArray([1.1, 2.2, 3.3, 4.4, 5.5]),
        )
        @test !AwkwardArray.is_valid(layout)
    end

    begin
        layout = AwkwardArray.ListArray{
            AwkwardArray.Index64,
            AwkwardArray.PrimitiveArray{Float64},
        }()
        sublayout = layout.content
        @test length(layout) == 0
        AwkwardArray.push!(sublayout, 1.1)
        AwkwardArray.push!(sublayout, 2.2)
        AwkwardArray.push!(sublayout, 3.3)
        AwkwardArray.end_list!(layout)
        @test length(layout) == 1
        AwkwardArray.end_list!(layout)
        @test length(layout) == 2
        AwkwardArray.push!(sublayout, 4.4)
        AwkwardArray.push!(sublayout, 5.5)
        AwkwardArray.end_list!(layout)
        @test length(layout) == 3
        @test layout == AwkwardArray.ListArray(
            [0, 3, 3],
            [3, 3, 5],
            AwkwardArray.PrimitiveArray([1.1, 2.2, 3.3, 4.4, 5.5]),
        )

        AwkwardArray.push_dummy!(layout)
        @test length(layout) == 4
        @test layout == AwkwardArray.ListArray(
            [0, 3, 3, 5],
            [3, 3, 5, 5],
            AwkwardArray.PrimitiveArray([1.1, 2.2, 3.3, 4.4, 5.5]),
        )
        @test AwkwardArray.is_valid(layout)
    end

    ### RegularArray #########################################################

    begin
        layout = AwkwardArray.RegularArray(
            AwkwardArray.PrimitiveArray([1.1, 2.2, 3.3, 4.4, 5.5, 6.6]),
            3,
        )
        @test AwkwardArray.is_valid(layout)
        @test length(layout) == 2
        @test layout[1] == AwkwardArray.PrimitiveArray([1.1, 2.2, 3.3])
        @test layout[2] == AwkwardArray.PrimitiveArray([4.4, 5.5, 6.6])
        @test layout[end] == AwkwardArray.PrimitiveArray([4.4, 5.5, 6.6])
    end

    begin
        layout = AwkwardArray.RegularArray(
            AwkwardArray.PrimitiveArray([1.1, 2.2, 3.3, 4.4, 5.5, 6.6]),
            2,
        )
        @test AwkwardArray.is_valid(layout)
        @test length(layout) == 3
        @test layout[1] == AwkwardArray.PrimitiveArray([1.1, 2.2])
        @test layout[2] == AwkwardArray.PrimitiveArray([3.3, 4.4])
        @test layout[3] == AwkwardArray.PrimitiveArray([5.5, 6.6])
        @test layout[end] == AwkwardArray.PrimitiveArray([5.5, 6.6])
        @test layout[1:3] == AwkwardArray.RegularArray(
            AwkwardArray.PrimitiveArray([1.1, 2.2, 3.3, 4.4]),
            2,
        )
        @test layout[2:4] == AwkwardArray.RegularArray(
            AwkwardArray.PrimitiveArray([3.3, 4.4, 5.5, 6.6]),
            2,
        )
        @test layout[2:3] ==
              AwkwardArray.RegularArray(AwkwardArray.PrimitiveArray([3.3, 4.4]), 2)
    end

    begin
        layout = AwkwardArray.RegularArray(
            AwkwardArray.PrimitiveArray{Float64}(),
            0,
            zeros_length = 5,
        )
        @test AwkwardArray.is_valid(layout)
        @test length(layout) == 5
        @test layout.size == 0
    end

    begin
        layout = AwkwardArray.RegularArray{AwkwardArray.PrimitiveArray{Float64}}()
        sublayout = layout.content
        @test length(layout) == 0
        AwkwardArray.push!(sublayout, 1.1)
        AwkwardArray.push!(sublayout, 2.2)
        AwkwardArray.push!(sublayout, 3.3)
        AwkwardArray.end_list!(layout)
        @test length(layout) == 1
        @test layout.size == 3
        AwkwardArray.push!(sublayout, 4.4)
        AwkwardArray.push!(sublayout, 5.5)
        AwkwardArray.push!(sublayout, 6.6)
        AwkwardArray.end_list!(layout)
        @test length(layout) == 2
        @test layout == AwkwardArray.RegularArray(
            AwkwardArray.PrimitiveArray([1.1, 2.2, 3.3, 4.4, 5.5, 6.6]),
            3,
        )

        AwkwardArray.push_dummy!(layout)
        @test length(layout) == 3
        @test layout == AwkwardArray.RegularArray(
            AwkwardArray.PrimitiveArray([1.1, 2.2, 3.3, 4.4, 5.5, 6.6, 0.0, 0.0, 0.0]),
            3,
        )
        @test AwkwardArray.is_valid(layout)
    end

    begin
        layout = AwkwardArray.RegularArray{AwkwardArray.PrimitiveArray{Float64}}()
        sublayout = layout.content
        @test length(layout) == 0
        AwkwardArray.push!(sublayout, 1.1)
        AwkwardArray.push!(sublayout, 2.2)
        AwkwardArray.end_list!(layout)
        @test length(layout) == 1
        @test layout.size == 2
        AwkwardArray.push!(sublayout, 3.3)
        AwkwardArray.push!(sublayout, 4.4)
        AwkwardArray.end_list!(layout)
        @test length(layout) == 2
        AwkwardArray.push!(sublayout, 5.5)
        AwkwardArray.push!(sublayout, 6.6)
        AwkwardArray.end_list!(layout)
        @test length(layout) == 3
        @test layout == AwkwardArray.RegularArray(
            AwkwardArray.PrimitiveArray([1.1, 2.2, 3.3, 4.4, 5.5, 6.6]),
            2,
        )

        AwkwardArray.push_dummy!(layout)
        @test length(layout) == 4
        @test layout == AwkwardArray.RegularArray(
            AwkwardArray.PrimitiveArray([1.1, 2.2, 3.3, 4.4, 5.5, 6.6, 0.0, 0.0]),
            2,
        )
        @test AwkwardArray.is_valid(layout)
    end

    begin
        layout = AwkwardArray.RegularArray{AwkwardArray.PrimitiveArray{Float64}}()
        sublayout = layout.content
        AwkwardArray.end_list!(layout)
        AwkwardArray.end_list!(layout)
        AwkwardArray.end_list!(layout)
        AwkwardArray.end_list!(layout)
        AwkwardArray.end_list!(layout)
        @test length(layout) == 5
        @test layout == AwkwardArray.RegularArray(
            AwkwardArray.PrimitiveArray{Float64}(),
            0,
            zeros_length = 5,
        )
    end

    ### ListType with behavior = :string #####################################

    begin
        AwkwardArray.is_valid(AwkwardArray.StringOffsetArray([0, 3, 3, 6], "onetwo"))
        AwkwardArray.is_valid(AwkwardArray.StringOffsetArray())

        AwkwardArray.is_valid(AwkwardArray.StringArray([0, 3, 3], [3, 3, 6], "onetwo"))
        AwkwardArray.is_valid(AwkwardArray.StringArray())

        AwkwardArray.is_valid(AwkwardArray.StringRegularArray("onetwo", 3))
        AwkwardArray.is_valid(AwkwardArray.StringRegularArray(3))
        AwkwardArray.is_valid(AwkwardArray.StringRegularArray())
    end

    begin
        layout = AwkwardArray.ListOffsetArray(
            [0, 3, 8, 9, 11, 14, 18],
            AwkwardArray.PrimitiveArray(
                [
                    0x68,
                    0x65,
                    0x79,
                    0x74,
                    0x68,
                    0x65,
                    0x72,
                    0x65,
                    0x24,
                    0xc2,
                    0xa2,
                    0xe2,
                    0x82,
                    0xac,
                    0xf0,
                    0x9f,
                    0x92,
                    0xb0,
                ],
                behavior = :char,
            ),
            behavior = :string,
        )

        @test layout[1] == "hey"
        @test layout[2] == "there"
        @test layout[3] == "\$"
        @test layout[4] == "¢"
        @test layout[5] == "€"
        @test layout[6] == "💰"

        @test Vector(layout) == ["hey", "there", "\$", "¢", "€", "💰"]

        AwkwardArray.push_dummy!(layout)
        @test Vector(layout) == ["hey", "there", "\$", "¢", "€", "💰", ""]
        @test AwkwardArray.is_valid(layout)
    end

    begin
        layout = AwkwardArray.ListArray(
            [0, 3, 8, 9, 11, 14],
            [3, 8, 9, 11, 14, 18],
            AwkwardArray.PrimitiveArray(
                [
                    0x68,
                    0x65,
                    0x79,
                    0x74,
                    0x68,
                    0x65,
                    0x72,
                    0x65,
                    0x24,
                    0xc2,
                    0xa2,
                    0xe2,
                    0x82,
                    0xac,
                    0xf0,
                    0x9f,
                    0x92,
                    0xb0,
                ],
                behavior = :char,
            ),
            behavior = :string,
        )

        @test layout[1] == "hey"
        @test layout[2] == "there"
        @test layout[3] == "\$"
        @test layout[4] == "¢"
        @test layout[5] == "€"
        @test layout[6] == "💰"

        @test Vector(layout) == ["hey", "there", "\$", "¢", "€", "💰"]

        AwkwardArray.push_dummy!(layout)
        @test Vector(layout) == ["hey", "there", "\$", "¢", "€", "💰", ""]
        @test AwkwardArray.is_valid(layout)
    end

    begin
        layout = AwkwardArray.RegularArray(
            AwkwardArray.PrimitiveArray(
                [0x6f, 0x6e, 0x65, 0x74, 0x77, 0x6f],
                behavior = :char,
            ),
            3,
            behavior = :string,
        )

        @test layout[1] == "one"
        @test layout[2] == "two"

        @test Vector(layout) == ["one", "two"]

        AwkwardArray.push_dummy!(layout)
        @test Vector(layout) == ["one", "two", "\0\0\0"]
        @test AwkwardArray.is_valid(layout)
    end

    ### ListType with behavior = :bytestring #################################

    begin
        AwkwardArray.is_valid(
            AwkwardArray.ByteStringOffsetArray(
                [0, 3, 3, 6],
                Vector{UInt8}([0x6f, 0x6e, 0x65, 0x74, 0x77, 0x6f]),
            ),
        )
        AwkwardArray.is_valid(AwkwardArray.ByteStringOffsetArray())

        AwkwardArray.is_valid(
            AwkwardArray.ByteStringArray(
                [0, 3, 3],
                [3, 3, 6],
                Vector{UInt8}([0x6f, 0x6e, 0x65, 0x74, 0x77, 0x6f]),
            ),
        )
        AwkwardArray.is_valid(AwkwardArray.ByteStringArray())

        AwkwardArray.is_valid(
            AwkwardArray.ByteStringRegularArray(
                Vector{UInt8}([0x6f, 0x6e, 0x65, 0x74, 0x77, 0x6f]),
                3,
            ),
        )
        AwkwardArray.is_valid(AwkwardArray.ByteStringRegularArray(3))
        AwkwardArray.is_valid(AwkwardArray.ByteStringRegularArray())
    end

    begin
        layout = AwkwardArray.ListOffsetArray(
            [0, 3, 8, 9, 11, 14, 18],
            AwkwardArray.PrimitiveArray(
                [
                    0x68,
                    0x65,
                    0x79,
                    0x74,
                    0x68,
                    0x65,
                    0x72,
                    0x65,
                    0x24,
                    0xc2,
                    0xa2,
                    0xe2,
                    0x82,
                    0xac,
                    0xf0,
                    0x9f,
                    0x92,
                    0xb0,
                ],
                behavior = :byte,
            ),
            behavior = :bytestring,
        )

        @test layout[1] == [0x68, 0x65, 0x79]
        @test layout[2] == [0x74, 0x68, 0x65, 0x72, 0x65]
        @test layout[3] == [0x24]
        @test layout[4] == [0xc2, 0xa2]
        @test layout[5] == [0xe2, 0x82, 0xac]
        @test layout[6] == [0xf0, 0x9f, 0x92, 0xb0]

        AwkwardArray.push_dummy!(layout)
        @test layout[7] == []
        @test AwkwardArray.is_valid(layout)
    end

    begin
        layout = AwkwardArray.ListArray(
            [0, 3, 8, 9, 11, 14],
            [3, 8, 9, 11, 14, 18],
            AwkwardArray.PrimitiveArray(
                [
                    0x68,
                    0x65,
                    0x79,
                    0x74,
                    0x68,
                    0x65,
                    0x72,
                    0x65,
                    0x24,
                    0xc2,
                    0xa2,
                    0xe2,
                    0x82,
                    0xac,
                    0xf0,
                    0x9f,
                    0x92,
                    0xb0,
                ],
                behavior = :byte,
            ),
            behavior = :bytestring,
        )

        @test layout[1] == [0x68, 0x65, 0x79]
        @test layout[2] == [0x74, 0x68, 0x65, 0x72, 0x65]
        @test layout[3] == [0x24]
        @test layout[4] == [0xc2, 0xa2]
        @test layout[5] == [0xe2, 0x82, 0xac]
        @test layout[6] == [0xf0, 0x9f, 0x92, 0xb0]

        AwkwardArray.push_dummy!(layout)
        @test layout[7] == []
        @test AwkwardArray.is_valid(layout)
    end

    begin
        layout = AwkwardArray.RegularArray(
            AwkwardArray.PrimitiveArray(
                [0x6f, 0x6e, 0x65, 0x74, 0x77, 0x6f],
                behavior = :byte,
            ),
            3,
            behavior = :bytestring,
        )

        @test layout[1] == [0x6f, 0x6e, 0x65]
        @test layout[2] == [0x74, 0x77, 0x6f]

        @test Vector(layout) == [[0x6f, 0x6e, 0x65], [0x74, 0x77, 0x6f]]

        AwkwardArray.push_dummy!(layout)
        @test Vector(layout) == [[0x6f, 0x6e, 0x65], [0x74, 0x77, 0x6f], [0x00, 0x00, 0x00]]
        @test AwkwardArray.is_valid(layout)
    end

    ### ListType with other parameters #######################################

    begin
        layout = AwkwardArray.ListOffsetArray(
            [0, 3, 3, 8],
            AwkwardArray.PrimitiveArray([0x68, 0x65, 0x79, 0x74, 0x68, 0x65, 0x72, 0x65],),
            parameters = AwkwardArray.Parameters("__doc__" => "nice list"),
        )

        @test AwkwardArray.get_parameter(layout, "__doc__") == "nice list"
        @test !AwkwardArray.has_parameter(layout, "__list__")
    end

    begin
        layout = AwkwardArray.ListArray(
            [0, 3, 3],
            [3, 3, 8],
            AwkwardArray.PrimitiveArray([0x68, 0x65, 0x79, 0x74, 0x68, 0x65, 0x72, 0x65],),
            parameters = AwkwardArray.Parameters("__doc__" => "nice list"),
        )

        @test AwkwardArray.get_parameter(layout, "__doc__") == "nice list"
        @test !AwkwardArray.has_parameter(layout, "__list__")
    end

    begin
        layout = AwkwardArray.RegularArray(
            AwkwardArray.PrimitiveArray([0x6f, 0x6e, 0x65, 0x74, 0x77, 0x6f]),
            3,
            parameters = AwkwardArray.Parameters("__doc__" => "nice list"),
        )

        @test AwkwardArray.get_parameter(layout, "__doc__") == "nice list"
        @test !AwkwardArray.has_parameter(layout, "__list__")
    end

    begin
        layout = AwkwardArray.ListOffsetArray(
            [0, 3, 3, 8],
            AwkwardArray.PrimitiveArray(
                [0x68, 0x65, 0x79, 0x74, 0x68, 0x65, 0x72, 0x65],
                behavior = :char,
            ),
            parameters = AwkwardArray.Parameters("__doc__" => "nice string"),
            behavior = :string,
        )

        @test AwkwardArray.get_parameter(layout, "__doc__") == "nice string"
        @test !AwkwardArray.has_parameter(layout, "__list__")
    end

    begin
        layout = AwkwardArray.ListArray(
            [0, 3, 3],
            [3, 3, 8],
            AwkwardArray.PrimitiveArray(
                [0x68, 0x65, 0x79, 0x74, 0x68, 0x65, 0x72, 0x65],
                behavior = :char,
            ),
            parameters = AwkwardArray.Parameters("__doc__" => "nice string"),
            behavior = :string,
        )

        @test AwkwardArray.get_parameter(layout, "__doc__") == "nice string"
        @test !AwkwardArray.has_parameter(layout, "__list__")
    end

    begin
        layout = AwkwardArray.RegularArray(
            AwkwardArray.PrimitiveArray(
                [0x6f, 0x6e, 0x65, 0x74, 0x77, 0x6f],
                behavior = :char,
            ),
            3,
            parameters = AwkwardArray.Parameters("__doc__" => "nice list"),
            behavior = :string,
        )

        @test AwkwardArray.get_parameter(layout, "__doc__") == "nice list"
        @test !AwkwardArray.has_parameter(layout, "__list__")
    end

    ### RecordArray ##########################################################

    begin
        layout = AwkwardArray.RecordArray(
            NamedTuple{(:a, :b)}((
                AwkwardArray.PrimitiveArray([1, 2, 3, 4, 5]),
                AwkwardArray.PrimitiveArray([1.1, 2.2, 3.3, 4.4, 5.5]),
            )),
        )
        @test AwkwardArray.is_valid(layout)
        @test length(layout) == 5
        @test layout[3][:a] == 3
        @test layout[3][:b] == 3.3
        @test layout[:a][3] == 3
        @test layout[:b][3] == 3.3

        @test layout == layout
        @test layout[3] == layout[3]

        tmp = 0.0
        for x in layout
            @test x[:b] < 6
            tmp += x[:b]
        end
        @test tmp == 16.5
    end

    begin
        layout = AwkwardArray.RecordArray(
            NamedTuple{(:a, :b)}((
                AwkwardArray.PrimitiveArray([1, 2, 3]),
                AwkwardArray.ListOffsetArray(
                    [0, 3, 3, 5],
                    AwkwardArray.PrimitiveArray([1.1, 2.2, 3.3, 4.4, 5.5]),
                ),
            )),
        )
        @test AwkwardArray.is_valid(layout)
        @test length(layout) == 3
        @test layout[3][:a] == 3
        @test layout[3][:b][1] == 4.4
        @test layout[:a][3] == 3
        @test layout[:b][3][1] == 4.4

        @test layout == layout
        @test layout[3] == layout[3]
        @test layout[1][:b] == AwkwardArray.PrimitiveArray([1.1, 2.2, 3.3])
        @test layout[2][:b] == AwkwardArray.PrimitiveArray([])
        @test layout[3][:b] == AwkwardArray.PrimitiveArray([4.4, 5.5])
        @test layout[:b][1] == AwkwardArray.PrimitiveArray([1.1, 2.2, 3.3])
        @test layout[:b][2] == AwkwardArray.PrimitiveArray([])
        @test layout[:b][3] == AwkwardArray.PrimitiveArray([4.4, 5.5])

        tmp = 0.0
        for x in layout
            for y in x[:b]
                @test y < 6
                tmp += y
            end
        end
        @test tmp == 16.5
    end

    begin
        layout = AwkwardArray.RecordArray(
            NamedTuple{(:a, :b)}((
                AwkwardArray.PrimitiveArray{Int64}(),
                AwkwardArray.ListOffsetArray{
                    AwkwardArray.Index64,
                    AwkwardArray.PrimitiveArray{Float64},
                }(),
            )),
        )
        a_layout = layout.contents[:a]
        b_layout = layout.contents[:b]
        b_sublayout = b_layout.content

        AwkwardArray.push!(a_layout, 1)
        AwkwardArray.push!(b_sublayout, 1.1)
        AwkwardArray.push!(b_sublayout, 2.2)
        AwkwardArray.push!(b_sublayout, 3.3)
        AwkwardArray.end_list!(b_layout)
        AwkwardArray.end_record!(layout)

        AwkwardArray.push!(a_layout, 2)
        AwkwardArray.end_list!(b_layout)
        AwkwardArray.end_record!(layout)

        AwkwardArray.push!(a_layout, 3)
        AwkwardArray.push!(b_sublayout, 4.4)
        AwkwardArray.push!(b_sublayout, 5.5)
        AwkwardArray.end_list!(b_layout)
        AwkwardArray.end_record!(layout)

        @test layout[:a] == AwkwardArray.PrimitiveArray([1, 2, 3])
        @test layout[:b] == AwkwardArray.ListOffsetArray(
            [0, 3, 3, 5],
            AwkwardArray.PrimitiveArray([1.1, 2.2, 3.3, 4.4, 5.5]),
        )

        @test layout == layout

        @test AwkwardArray.RecordArray(
            NamedTuple{(:a,)}((AwkwardArray.PrimitiveArray([1, 2, 3]),)),
        ) == AwkwardArray.RecordArray(
            NamedTuple{(:a,)}((AwkwardArray.PrimitiveArray([1, 2, 3]),)),
        )

        @test layout == AwkwardArray.RecordArray(
            NamedTuple{(:a, :b)}((
                AwkwardArray.PrimitiveArray([1, 2, 3]),
                AwkwardArray.ListOffsetArray(
                    [0, 3, 3, 5],
                    AwkwardArray.PrimitiveArray([1.1, 2.2, 3.3, 4.4, 5.5]),
                ),
            )),
        )

        @test layout[1] == layout[1]
        @test layout[2] == layout[2]
        @test layout[3] == layout[3]

        @test layout[3] == AwkwardArray.Record(
            AwkwardArray.RecordArray(
                NamedTuple{(:a, :b)}((
                    AwkwardArray.PrimitiveArray([1, 2, 3]),
                    AwkwardArray.ListOffsetArray(
                        [0, 3, 3, 5],
                        AwkwardArray.PrimitiveArray([1.1, 2.2, 3.3, 4.4, 5.5]),
                    ),
                )),
            ),
            3,
        )

        @test layout[3] == AwkwardArray.Record(
            AwkwardArray.RecordArray(
                NamedTuple{(:a, :b)}((
                    AwkwardArray.PrimitiveArray([3]),
                    AwkwardArray.ListOffsetArray(
                        [0, 2],
                        AwkwardArray.PrimitiveArray([4.4, 5.5]),
                    ),
                )),
            ),
            1,
        )

        AwkwardArray.push_dummy!(layout)
        @test layout == AwkwardArray.RecordArray(
            NamedTuple{(:a, :b)}((
                AwkwardArray.PrimitiveArray([1, 2, 3, 0]),
                AwkwardArray.ListOffsetArray(
                    [0, 3, 3, 5, 5],
                    AwkwardArray.PrimitiveArray([1.1, 2.2, 3.3, 4.4, 5.5]),
                ),
            )),
        )
        @test layout[4] == AwkwardArray.Record(
            AwkwardArray.RecordArray(
                NamedTuple{(:a, :b)}((
                    AwkwardArray.PrimitiveArray([0]),
                    AwkwardArray.ListOffsetArray([0, 0], AwkwardArray.PrimitiveArray([])),
                )),
            ),
            1,
        )
        @test AwkwardArray.is_valid(layout)
    end

    begin
        layout_2 = AwkwardArray.RecordArray(
            NamedTuple{(:a, :b)}((
                AwkwardArray.PrimitiveArray([1, 2]),
                AwkwardArray.ListOffsetArray(
                    [0, 3, 3],
                    AwkwardArray.PrimitiveArray([1.1, 2.2, 3.3]),
                ),
            )),
        )

        layout_3 = AwkwardArray.RecordArray(
            NamedTuple{(:a, :b)}((
                AwkwardArray.PrimitiveArray([1, 2, 3]),
                AwkwardArray.ListOffsetArray(
                    [0, 3, 3, 5],
                    AwkwardArray.PrimitiveArray([1.1, 2.2, 3.3, 4.4, 5.5]),
                ),
            )),
        )

        @test layout_2 == AwkwardArray.copy(layout_3, length = 2)
    end

    begin
        layout = AwkwardArray.RecordArray{
            NamedTuple{
                (:a, :b),
                Tuple{
                    AwkwardArray.PrimitiveArray{Int64},
                    AwkwardArray.ListOffsetArray{
                        AwkwardArray.Index64,
                        AwkwardArray.PrimitiveArray{Float64},
                    },
                },
            },
        }()
        @test AwkwardArray.is_valid(layout)
        @test length(layout) == 0

        a_layout = layout.contents[:a]
        b_layout = layout.contents[:b]
        b_sublayout = b_layout.content

        AwkwardArray.push!(a_layout, 1)
        AwkwardArray.push!(b_sublayout, 1.1)
        AwkwardArray.push!(b_sublayout, 2.2)
        AwkwardArray.push!(b_sublayout, 3.3)
        AwkwardArray.end_list!(b_layout)
        AwkwardArray.end_record!(layout)
        @test length(layout) == 1

        AwkwardArray.push!(a_layout, 2)
        AwkwardArray.end_list!(b_layout)
        AwkwardArray.end_record!(layout)
        @test length(layout) == 2

        AwkwardArray.push!(a_layout, 3)
        AwkwardArray.push!(b_sublayout, 4.4)
        AwkwardArray.push!(b_sublayout, 5.5)
        AwkwardArray.end_list!(b_layout)
        AwkwardArray.end_record!(layout)
        @test length(layout) == 3

        @test layout == AwkwardArray.RecordArray(
            NamedTuple{(:a, :b)}((
                AwkwardArray.PrimitiveArray([1, 2, 3]),
                AwkwardArray.ListOffsetArray(
                    [0, 3, 3, 5],
                    AwkwardArray.PrimitiveArray([1.1, 2.2, 3.3, 4.4, 5.5]),
                ),
            )),
        )
    end

    ### TupleArray ##########################################################

    begin
        layout = AwkwardArray.TupleArray((
            AwkwardArray.PrimitiveArray([1, 2, 3, 4, 5]),
            AwkwardArray.PrimitiveArray([1.1, 2.2, 3.3, 4.4, 5.5]),
        ),)
        @test AwkwardArray.is_valid(layout)
        @test length(layout) == 5
        @test layout[3][1] == 3
        @test layout[3][2] == 3.3
        @test AwkwardArray.slot(layout, 1)[3] == 3
        @test AwkwardArray.slot(layout, 2)[3] == 3.3
        @test layout == layout
        @test layout[3] == layout[3]

        tmp = 0.0
        for x in layout
            @test x[2] < 6
            tmp += x[2]
        end
        @test tmp == 16.5
    end

    begin
        layout = AwkwardArray.TupleArray((
            AwkwardArray.PrimitiveArray([1, 2, 3]),
            AwkwardArray.ListOffsetArray(
                [0, 3, 3, 5],
                AwkwardArray.PrimitiveArray([1.1, 2.2, 3.3, 4.4, 5.5]),
            ),
        ),)
        @test AwkwardArray.is_valid(layout)
        @test length(layout) == 3
        @test layout[3][1] == 3
        @test layout[3][2][1] == 4.4
        @test AwkwardArray.slot(layout, 1)[3] == 3
        @test AwkwardArray.slot(layout, 2)[3][1] == 4.4

        @test layout == layout
        @test layout[3] == layout[3]
        @test layout[1][2] == AwkwardArray.PrimitiveArray([1.1, 2.2, 3.3])
        @test layout[2][2] == AwkwardArray.PrimitiveArray([])
        @test layout[3][2] == AwkwardArray.PrimitiveArray([4.4, 5.5])
        @test AwkwardArray.slot(layout, 2)[1] ==
              AwkwardArray.PrimitiveArray([1.1, 2.2, 3.3])
        @test AwkwardArray.slot(layout, 2)[2] == AwkwardArray.PrimitiveArray([])
        @test AwkwardArray.slot(layout, 2)[3] == AwkwardArray.PrimitiveArray([4.4, 5.5])

        tmp = 0.0
        for x in layout
            for y in x[2]
                @test y < 6
                tmp += y
            end
        end
        @test tmp == 16.5
    end

    begin
        layout = AwkwardArray.TupleArray((
            AwkwardArray.PrimitiveArray{Int64}(),
            AwkwardArray.ListOffsetArray{
                AwkwardArray.Index64,
                AwkwardArray.PrimitiveArray{Float64},
            }(),
        ),)
        a_layout = layout.contents[1]
        b_layout = layout.contents[2]
        b_sublayout = b_layout.content

        AwkwardArray.push!(a_layout, 1)
        AwkwardArray.push!(b_sublayout, 1.1)
        AwkwardArray.push!(b_sublayout, 2.2)
        AwkwardArray.push!(b_sublayout, 3.3)
        AwkwardArray.end_list!(b_layout)
        AwkwardArray.end_tuple!(layout)

        AwkwardArray.push!(a_layout, 2)
        AwkwardArray.end_list!(b_layout)
        AwkwardArray.end_tuple!(layout)

        AwkwardArray.push!(a_layout, 3)
        AwkwardArray.push!(b_sublayout, 4.4)
        AwkwardArray.push!(b_sublayout, 5.5)
        AwkwardArray.end_list!(b_layout)
        AwkwardArray.end_tuple!(layout)

        @test AwkwardArray.slot(layout, 1) == AwkwardArray.PrimitiveArray([1, 2, 3])
        @test AwkwardArray.slot(layout, 2) == AwkwardArray.ListOffsetArray(
            [0, 3, 3, 5],
            AwkwardArray.PrimitiveArray([1.1, 2.2, 3.3, 4.4, 5.5]),
        )

        @test layout == layout

        @test AwkwardArray.TupleArray((AwkwardArray.PrimitiveArray([1, 2, 3]),),) ==
              AwkwardArray.TupleArray((AwkwardArray.PrimitiveArray([1, 2, 3]),),)

        @test layout == AwkwardArray.TupleArray((
            AwkwardArray.PrimitiveArray([1, 2, 3]),
            AwkwardArray.ListOffsetArray(
                [0, 3, 3, 5],
                AwkwardArray.PrimitiveArray([1.1, 2.2, 3.3, 4.4, 5.5]),
            ),
        ),)

        @test layout[1] == layout[1]
        @test layout[2] == layout[2]
        @test layout[3] == layout[3]

        @test layout[3] == AwkwardArray.Tuple(
            AwkwardArray.TupleArray((
                AwkwardArray.PrimitiveArray([1, 2, 3]),
                AwkwardArray.ListOffsetArray(
                    [0, 3, 3, 5],
                    AwkwardArray.PrimitiveArray([1.1, 2.2, 3.3, 4.4, 5.5]),
                ),
            ),),
            3,
        )

        @test layout[3] == AwkwardArray.Tuple(
            AwkwardArray.TupleArray((
                AwkwardArray.PrimitiveArray([3]),
                AwkwardArray.ListOffsetArray(
                    [0, 2],
                    AwkwardArray.PrimitiveArray([4.4, 5.5]),
                ),
            ),),
            1,
        )

        AwkwardArray.push_dummy!(layout)
        @test layout == AwkwardArray.TupleArray((
            AwkwardArray.PrimitiveArray([1, 2, 3, 0]),
            AwkwardArray.ListOffsetArray(
                [0, 3, 3, 5, 5],
                AwkwardArray.PrimitiveArray([1.1, 2.2, 3.3, 4.4, 5.5]),
            ),
        ),)
        @test layout[4] == AwkwardArray.Tuple(
            AwkwardArray.TupleArray((
                AwkwardArray.PrimitiveArray([0]),
                AwkwardArray.ListOffsetArray([0, 0], AwkwardArray.PrimitiveArray([])),
            ),),
            1,
        )
        @test AwkwardArray.is_valid(layout)
    end

    begin
        layout_2 = AwkwardArray.TupleArray((
            AwkwardArray.PrimitiveArray([1, 2]),
            AwkwardArray.ListOffsetArray(
                [0, 3, 3],
                AwkwardArray.PrimitiveArray([1.1, 2.2, 3.3]),
            ),
        ),)

        layout_3 = AwkwardArray.TupleArray((
            AwkwardArray.PrimitiveArray([1, 2, 3]),
            AwkwardArray.ListOffsetArray(
                [0, 3, 3, 5],
                AwkwardArray.PrimitiveArray([1.1, 2.2, 3.3, 4.4, 5.5]),
            ),
        ),)

        @test layout_2 == AwkwardArray.copy(layout_3, length = 2)
    end

    begin
        layout = AwkwardArray.TupleArray{
            Tuple{
                AwkwardArray.PrimitiveArray{Int64},
                AwkwardArray.ListOffsetArray{
                    AwkwardArray.Index64,
                    AwkwardArray.PrimitiveArray{Float64},
                },
            },
        }()
        @test AwkwardArray.is_valid(layout)
        @test length(layout) == 0

        a_layout = layout.contents[1]
        b_layout = layout.contents[2]
        b_sublayout = b_layout.content

        AwkwardArray.push!(a_layout, 1)
        AwkwardArray.push!(b_sublayout, 1.1)
        AwkwardArray.push!(b_sublayout, 2.2)
        AwkwardArray.push!(b_sublayout, 3.3)
        AwkwardArray.end_list!(b_layout)
        AwkwardArray.end_tuple!(layout)
        @test length(layout) == 1

        AwkwardArray.push!(a_layout, 2)
        AwkwardArray.end_list!(b_layout)
        AwkwardArray.end_tuple!(layout)
        @test length(layout) == 2

        AwkwardArray.push!(a_layout, 3)
        AwkwardArray.push!(b_sublayout, 4.4)
        AwkwardArray.push!(b_sublayout, 5.5)
        AwkwardArray.end_list!(b_layout)
        AwkwardArray.end_tuple!(layout)
        @test length(layout) == 3

        @test layout == AwkwardArray.TupleArray((
            AwkwardArray.PrimitiveArray([1, 2, 3]),
            AwkwardArray.ListOffsetArray(
                [0, 3, 3, 5],
                AwkwardArray.PrimitiveArray([1.1, 2.2, 3.3, 4.4, 5.5]),
            ),
        ),)
    end

    ### IndexedArray #########################################################

    begin
        layout = AwkwardArray.IndexedArray(
            [4, 3, 3, 0],
            AwkwardArray.PrimitiveArray([1.1, 2.2, 3.3, 4.4, 5.5]),
        )
        @test AwkwardArray.is_valid(layout)
        @test length(layout) == 4
        @test layout[1] == 5.5
        @test layout[2] == 4.4
        @test layout[3] == 4.4
        @test layout[4] == 1.1
        @test layout[2:4] == AwkwardArray.PrimitiveArray([4.4, 4.4, 1.1])
        tmp = 0.0
        for x in layout
            @test x < 6
            tmp += x
        end
        @test tmp == 15.4

        AwkwardArray.push!(layout, 6.6)
        @test length(layout) == 5
        @test layout[5] == 6.6

        AwkwardArray.push!(layout, 7.7)
        @test length(layout) == 6
        @test layout[6] == 7.7
        @test layout.index == [4, 3, 3, 0, 5, 6]
        @test layout == AwkwardArray.PrimitiveArray([5.5, 4.4, 4.4, 1.1, 6.6, 7.7])

        AwkwardArray.push_dummy!(layout)
        @test layout == AwkwardArray.PrimitiveArray([5.5, 4.4, 4.4, 1.1, 6.6, 7.7, 0.0])
        @test layout.index == [4, 3, 3, 0, 5, 6, 7]
        @test AwkwardArray.is_valid(layout)
    end

    begin
        layout = AwkwardArray.IndexedArray(
            [2, 0, 0, 1],
            AwkwardArray.ListOffsetArray(
                [0, 3, 3, 5],
                AwkwardArray.PrimitiveArray([1.1, 2.2, 3.3, 4.4, 5.5]),
            ),
        )
        @test AwkwardArray.is_valid(layout)
        @test length(layout) == 4
        @test layout[1] == AwkwardArray.PrimitiveArray([4.4, 5.5])
        @test layout[2] == AwkwardArray.PrimitiveArray([1.1, 2.2, 3.3])
        @test layout[3] == AwkwardArray.PrimitiveArray([1.1, 2.2, 3.3])
        @test layout[4] == AwkwardArray.PrimitiveArray([])

        sublayout = layout.content.content
        AwkwardArray.push!(sublayout, 6.6)
        AwkwardArray.push!(sublayout, 7.7)
        AwkwardArray.end_list!(layout)
        @test length(layout) == 5
        @test layout[5] == AwkwardArray.PrimitiveArray([6.6, 7.7])
        @test layout.index == [2, 0, 0, 1, 3]

        @test layout == AwkwardArray.ListArray(
            [3, 0, 0, 3, 5],
            [5, 3, 3, 3, 7],
            AwkwardArray.PrimitiveArray([1.1, 2.2, 3.3, 4.4, 5.5, 6.6, 7.7]),
        )
        AwkwardArray.push_dummy!(layout)
        @test layout == AwkwardArray.ListArray(
            [3, 0, 0, 3, 5, 7],
            [5, 3, 3, 3, 7, 7],
            AwkwardArray.PrimitiveArray([1.1, 2.2, 3.3, 4.4, 5.5, 6.6, 7.7]),
        )
        @test AwkwardArray.is_valid(layout)
    end

    begin
        layout = AwkwardArray.IndexedArray(
            [3, 4, 0, 0, 1, 2],
            AwkwardArray.RecordArray(
                NamedTuple{(:a, :b)}((
                    AwkwardArray.PrimitiveArray([1, 2, 3, 4, 5]),
                    AwkwardArray.PrimitiveArray([1.1, 2.2, 3.3, 4.4, 5.5]),
                )),
            ),
        )
        @test AwkwardArray.is_valid(layout)
        @test length(layout) == 6
        @test layout[1][:a] == 4
        @test layout[1][:b] == 4.4
        @test layout[end][:a] == 3
        @test layout[end][:b] == 3.3
        @test layout[:a][1] == 4
        @test layout[:b][1] == 4.4
        @test layout[:a][end] == 3
        @test layout[:b][end] == 3.3

        a_layout = layout.content.contents[:a]
        b_layout = layout.content.contents[:b]

        AwkwardArray.push!(a_layout, 6)
        AwkwardArray.push!(b_layout, 6.6)
        AwkwardArray.end_record!(layout)
        @test length(layout) == 7
        @test layout[end][:a] == 6
        @test layout[end][:b] == 6.6
        @test layout.index == [3, 4, 0, 0, 1, 2, 5]

        AwkwardArray.push_dummy!(layout)
        @test length(layout) == 8
        @test layout[end][:a] == 0
        @test layout[end][:b] == 0.0
        @test layout.index == [3, 4, 0, 0, 1, 2, 5, 6]
        @test AwkwardArray.is_valid(layout)
    end

    ### IndexedOptionArray ###################################################

    begin
        layout = AwkwardArray.IndexedOptionArray(
            [4, 3, 3, -1, -1, 0],
            AwkwardArray.PrimitiveArray([1.1, 2.2, 3.3, 4.4, 5.5]),
        )
        @test AwkwardArray.is_valid(layout)
        @test length(layout) == 6
        @test layout[1] == 5.5
        @test layout[2] == 4.4
        @test layout[3] == 4.4
        @test ismissing(layout[4])
        @test ismissing(layout[5])
        @test layout[6] == 1.1
        @test layout[2:3] == AwkwardArray.PrimitiveArray([4.4, 4.4])
        tmp = 0.0
        for x in layout
            if !ismissing(x)
                @test x < 6
                tmp += x
            end
        end
        @test tmp == 15.4

        AwkwardArray.push!(layout, 6.6)
        @test length(layout) == 7
        @test layout[7] == 6.6

        AwkwardArray.push_null!(layout)
        @test length(layout) == 8
        @test ismissing(layout[8])
        AwkwardArray.push_null!(layout)
        @test length(layout) == 9
        @test ismissing(layout[9])

        AwkwardArray.push!(layout, 7.7)
        @test length(layout) == 10
        @test layout[10] == 7.7
        @test layout.index == [4, 3, 3, -1, -1, 0, 5, -1, -1, 6]

        AwkwardArray.push_dummy!(layout)
        @test length(layout) == 11
        @test ismissing(layout[11])
        @test layout.index == [4, 3, 3, -1, -1, 0, 5, -1, -1, 6, -1]
        @test AwkwardArray.is_valid(layout)
    end

    ### ByteMaskedArray ######################################################

    begin
        layout = AwkwardArray.ByteMaskedArray(
            [false, true, true, false, false],
            AwkwardArray.PrimitiveArray([1.1, 2.2, 3.3, 4.4, 5.5]),
            valid_when = false,
        )
        @test AwkwardArray.is_valid(layout)
        @test length(layout) == 5
        @test layout[1] == 1.1
        @test ismissing(layout[2])
        @test ismissing(layout[3])
        @test layout[4] == 4.4
        @test layout[5] == 5.5
        @test layout[4:5] == AwkwardArray.PrimitiveArray([4.4, 5.5])
        tmp = 0.0
        for x in layout
            if !ismissing(x)
                @test x < 6
                tmp += x
            end
        end
        @test tmp == 11.0

        AwkwardArray.push!(layout, 6.6)
        @test length(layout) == 6
        @test layout[6] == 6.6

        AwkwardArray.push_null!(layout)
        @test length(layout) == 7
        @test ismissing(layout[7])

        AwkwardArray.push_dummy!(layout)
        @test length(layout) == 8
        @test ismissing(layout[8])
        @test AwkwardArray.is_valid(layout)
    end

    begin
        layout = AwkwardArray.ByteMaskedArray(
            [true, true, false],
            AwkwardArray.ListOffsetArray(
                [0, 3, 3, 5],
                AwkwardArray.PrimitiveArray([1.1, 2.2, 3.3, 4.4, 5.5]),
            ),
            valid_when = true,
        )
        @test AwkwardArray.is_valid(layout)
        @test length(layout) == 3

        sublayout = layout.content.content

        AwkwardArray.push!(sublayout, 6.6)
        AwkwardArray.push!(sublayout, 7.7)
        AwkwardArray.push!(sublayout, 8.8)
        AwkwardArray.push!(sublayout, 9.9)
        AwkwardArray.end_list!(layout)

        @test length(layout) == 4
        @test layout[4] == AwkwardArray.PrimitiveArray([6.6, 7.7, 8.8, 9.9])

        AwkwardArray.push_null!(layout)
        @test length(layout) == 5
        @test ismissing(layout[5])

        AwkwardArray.push_dummy!(layout)
        @test length(layout) == 6
        @test ismissing(layout[6])
        @test AwkwardArray.is_valid(layout)
    end

    begin
        layout = AwkwardArray.ByteMaskedArray(
            [false, false, true, true, false],
            AwkwardArray.RecordArray(
                NamedTuple{(:a, :b)}((
                    AwkwardArray.PrimitiveArray([1, 2, 3, 4, 5]),
                    AwkwardArray.PrimitiveArray([1.1, 2.2, 3.3, 4.4, 5.5]),
                )),
            ),
            valid_when = false,
        )
        @test AwkwardArray.is_valid(layout)
        @test length(layout) == 5

        a_layout = layout.content.contents[:a]
        b_layout = layout.content.contents[:b]

        AwkwardArray.push!(a_layout, 6)
        AwkwardArray.push!(b_layout, 6.6)
        AwkwardArray.end_record!(layout)
        @test length(layout) == 6
        @test layout[6][:a] == 6
        @test layout[6][:b] == 6.6
        @test layout[:a][6] == 6
        @test layout[:b][6] == 6.6

        AwkwardArray.push_null!(layout)
        @test length(layout) == 7
        @test ismissing(layout[7])

        AwkwardArray.push_dummy!(layout)
        @test length(layout) == 8
        @test ismissing(layout[8])
        @test AwkwardArray.is_valid(layout)
    end

    ### BitMaskedArray #######################################################

    begin
        layout = AwkwardArray.BitMaskedArray(
            BitVector([false, true, true, false, false]),
            AwkwardArray.PrimitiveArray([1.1, 2.2, 3.3, 4.4, 5.5]),
            valid_when = false,
        )
        @test AwkwardArray.is_valid(layout)
        @test length(layout) == 5
        @test layout[1] == 1.1
        @test ismissing(layout[2])
        @test ismissing(layout[3])
        @test layout[4] == 4.4
        @test layout[5] == 5.5
        @test layout[4:5] == AwkwardArray.PrimitiveArray([4.4, 5.5])
        tmp = 0.0
        for x in layout
            if !ismissing(x)
                @test x < 6
                tmp += x
            end
        end
        @test tmp == 11.0

        AwkwardArray.push!(layout, 6.6)
        @test length(layout) == 6
        @test layout[6] == 6.6

        AwkwardArray.push_null!(layout)
        @test length(layout) == 7
        @test ismissing(layout[7])

        AwkwardArray.push_dummy!(layout)
        @test length(layout) == 8
        @test ismissing(layout[8])
        @test AwkwardArray.is_valid(layout)
    end

    begin
        layout = AwkwardArray.BitMaskedArray(
            BitVector([true, true, false]),
            AwkwardArray.ListOffsetArray(
                [0, 3, 3, 5],
                AwkwardArray.PrimitiveArray([1.1, 2.2, 3.3, 4.4, 5.5]),
            ),
            valid_when = true,
        )
        @test AwkwardArray.is_valid(layout)
        @test length(layout) == 3

        sublayout = layout.content.content

        AwkwardArray.push!(sublayout, 6.6)
        AwkwardArray.push!(sublayout, 7.7)
        AwkwardArray.push!(sublayout, 8.8)
        AwkwardArray.push!(sublayout, 9.9)
        AwkwardArray.end_list!(layout)

        @test length(layout) == 4
        @test layout[4] == AwkwardArray.PrimitiveArray([6.6, 7.7, 8.8, 9.9])

        AwkwardArray.push_null!(layout)
        @test length(layout) == 5
        @test ismissing(layout[5])

        AwkwardArray.push_dummy!(layout)
        @test length(layout) == 6
        @test ismissing(layout[6])
        @test AwkwardArray.is_valid(layout)
    end

    begin
        layout = AwkwardArray.BitMaskedArray(
            BitVector([false, false, true, true, false]),
            AwkwardArray.RecordArray(
                NamedTuple{(:a, :b)}((
                    AwkwardArray.PrimitiveArray([1, 2, 3, 4, 5]),
                    AwkwardArray.PrimitiveArray([1.1, 2.2, 3.3, 4.4, 5.5]),
                )),
            ),
            valid_when = false,
        )
        @test AwkwardArray.is_valid(layout)
        @test length(layout) == 5

        a_layout = layout.content.contents[:a]
        b_layout = layout.content.contents[:b]

        AwkwardArray.push!(a_layout, 6)
        AwkwardArray.push!(b_layout, 6.6)
        AwkwardArray.end_record!(layout)
        @test length(layout) == 6
        @test layout[6][:a] == 6
        @test layout[6][:b] == 6.6
        @test layout[:a][6] == 6
        @test layout[:b][6] == 6.6

        AwkwardArray.push_null!(layout)
        @test length(layout) == 7
        @test ismissing(layout[7])

        AwkwardArray.push_dummy!(layout)
        @test length(layout) == 8
        @test ismissing(layout[8])
        @test AwkwardArray.is_valid(layout)
    end

    ### UnmaskedArray ########################################################

    begin
        layout = AwkwardArray.UnmaskedArray(
            AwkwardArray.PrimitiveArray([1.1, 2.2, 3.3, 4.4, 5.5]),
        )
        @test AwkwardArray.is_valid(layout)
        @test length(layout) == 5
        @test layout[1] == 1.1
        @test layout[2] == 2.2
        @test layout[3] == 3.3
        @test layout[4] == 4.4
        @test layout[5] == 5.5
        @test layout[4:5] == AwkwardArray.PrimitiveArray([4.4, 5.5])
        tmp = 0.0
        for x in layout
            if !ismissing(x)
                @test x < 6
                tmp += x
            end
        end
        @test tmp == 16.5

        AwkwardArray.push!(layout, 6.6)
        @test length(layout) == 6
        @test layout[6] == 6.6

        AwkwardArray.push_dummy!(layout)
        @test length(layout) == 7
        @test layout[7] == 0.0
        @test AwkwardArray.is_valid(layout)
    end

    begin
        layout = AwkwardArray.UnmaskedArray(
            AwkwardArray.ListOffsetArray(
                [0, 3, 3, 5],
                AwkwardArray.PrimitiveArray([1.1, 2.2, 3.3, 4.4, 5.5]),
            ),
        )
        @test AwkwardArray.is_valid(layout)
        @test length(layout) == 3

        sublayout = layout.content.content

        AwkwardArray.push!(sublayout, 6.6)
        AwkwardArray.push!(sublayout, 7.7)
        AwkwardArray.push!(sublayout, 8.8)
        AwkwardArray.push!(sublayout, 9.9)
        AwkwardArray.end_list!(layout)

        @test length(layout) == 4
        @test layout[4] == AwkwardArray.PrimitiveArray([6.6, 7.7, 8.8, 9.9])

        AwkwardArray.push_dummy!(layout)
        @test length(layout) == 5
        @test layout[5] == AwkwardArray.PrimitiveArray([])
        @test AwkwardArray.is_valid(layout)
    end

    begin
        layout = AwkwardArray.UnmaskedArray(
            AwkwardArray.RecordArray(
                NamedTuple{(:a, :b)}((
                    AwkwardArray.PrimitiveArray([1, 2, 3, 4, 5]),
                    AwkwardArray.PrimitiveArray([1.1, 2.2, 3.3, 4.4, 5.5]),
                )),
            ),
        )
        @test AwkwardArray.is_valid(layout)
        @test length(layout) == 5

        a_layout = layout.content.contents[:a]
        b_layout = layout.content.contents[:b]

        AwkwardArray.push!(a_layout, 6)
        AwkwardArray.push!(b_layout, 6.6)
        AwkwardArray.end_record!(layout)
        @test length(layout) == 6
        @test layout[6][:a] == 6
        @test layout[6][:b] == 6.6
        @test layout[:a][6] == 6
        @test layout[:b][6] == 6.6

        AwkwardArray.push_dummy!(layout)
        @test length(layout) == 7
        @test layout[7][:a] == 0
        @test layout[7][:b] == 0.0
        @test layout[:a][7] == 0
        @test layout[:b][7] == 0.0
        @test AwkwardArray.is_valid(layout)
    end

    ### UnionArray ###########################################################

    begin
        layout = AwkwardArray.UnionArray(
            Vector{Int8}([0, 0, 0, 1]),
            [0, 1, 2, 0],
            (
                AwkwardArray.PrimitiveArray([1.1, 2.2, 3.3]),
                AwkwardArray.ListOffsetArray(
                    [0, 2],
                    AwkwardArray.PrimitiveArray([4.4, 5.5]),
                ),
            ),
        )
        @test AwkwardArray.is_valid(layout)
        @test length(layout) == 4
        @test layout[1] == 1.1
        @test layout[2] == 2.2
        @test layout[3] == 3.3
        @test layout[4] == AwkwardArray.PrimitiveArray([4.4, 5.5])

        tmp = 0.0
        for x in layout
            if isa(x, AwkwardArray.PrimitiveArray)
                for y in x
                    @test y < 6
                    tmp += y
                end
            else
                @test x < 6
                tmp += x
            end
        end
        @test tmp == 16.5

        @test layout == layout
    end

    begin
        layout = AwkwardArray.UnionArray{
            AwkwardArray.Index8,
            AwkwardArray.Index64,
            Tuple{
                AwkwardArray.PrimitiveArray{Float64},
                AwkwardArray.ListOffsetArray{
                    AwkwardArray.Index64,
                    AwkwardArray.PrimitiveArray{Float64},
                },
            },
        }()
        @test AwkwardArray.is_valid(layout)
        @test length(layout) == 0

        special1 = AwkwardArray.specialization(layout, 1)
        special2 = AwkwardArray.specialization(layout, 2)
        subspecial2 = special2.tagged.content

        AwkwardArray.push!(special1, 1.1)
        @test length(layout) == 1
        @test layout[1] == 1.1

        AwkwardArray.push!(subspecial2, 2.2)
        AwkwardArray.push!(subspecial2, 3.3)
        AwkwardArray.end_list!(special2)
        @test length(layout) == 2
        @test layout[2][1] == 2.2
        @test layout[2][2] == 3.3

        @test layout == AwkwardArray.UnionArray(
            Vector{Int8}([0, 1]),
            [0, 0],
            (
                AwkwardArray.PrimitiveArray([1.1]),
                AwkwardArray.ListOffsetArray(
                    [0, 2],
                    AwkwardArray.PrimitiveArray([2.2, 3.3]),
                ),
            ),
        )

        AwkwardArray.push_dummy!(special1)
        @test layout == AwkwardArray.UnionArray(
            Vector{Int8}([0, 1, 0]),
            [0, 0, 1],
            (
                AwkwardArray.PrimitiveArray([1.1, 0.0]),
                AwkwardArray.ListOffsetArray(
                    [0, 2],
                    AwkwardArray.PrimitiveArray([2.2, 3.3]),
                ),
            ),
        )

        AwkwardArray.push_dummy!(special2)
        @test layout == AwkwardArray.UnionArray(
            Vector{Int8}([0, 1, 0, 1]),
            [0, 0, 1, 1],
            (
                AwkwardArray.PrimitiveArray([1.1, 0.0]),
                AwkwardArray.ListOffsetArray(
                    [0, 2, 2],
                    AwkwardArray.PrimitiveArray([2.2, 3.3]),
                ),
            ),
        )

        @test AwkwardArray.is_valid(layout)
    end

end   # @testset "AwkwardArray.jl"
