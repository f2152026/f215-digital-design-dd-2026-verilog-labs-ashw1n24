// cla64_flat.v

module cla64_flat(
    input  [63:0] a,
    input  [63:0] b,
    input         cin,
    output [63:0] sum,
    output        cout
);

    wire [63:0] p, g;
    wire [64:1] c;

    // ------------------------------------------------------------
    // Generate and propagate signals
    // ------------------------------------------------------------

    genvar i;

    generate
        for (i = 0; i < 64; i = i + 1) begin : gen_pg
            xor #(2) (p[i], a[i], b[i]);
            and #(2) (g[i], a[i], b[i]);
        end
    endgenerate


    // ------------------------------------------------------------
    // Function for a DIRECT carry-lookahead equation
    //
    // For example:
    //
    // c1 = g0 + p0 cin
    //
    // c2 = g1 + p1 g0 + p1 p0 cin
    //
    // c3 = g2 + p2 g1 + p2 p1 g0
    //            + p2 p1 p0 cin
    //
    // It does NOT use c[k-1], so the carries are not rippled.
    // ------------------------------------------------------------

    function automatic lookahead_carry;

        input [63:0] p_in;
        input [63:0] g_in;
        input        cin_in;
        input integer n;

        integer j;
        reg propagate_chain;

        begin

            // First term: g[n-1]
            lookahead_carry = g_in[n-1];

            // Begin product of propagate terms
            propagate_chain = p_in[n-1];

            // Add:
            // p[n-1] g[n-2]
            // p[n-1] p[n-2] g[n-3]
            // ...
            for (j = n - 2; j >= 0; j = j - 1) begin
                lookahead_carry =
                    lookahead_carry |
                    (propagate_chain & g_in[j]);

                propagate_chain =
                    propagate_chain & p_in[j];
            end

            // Final term:
            // p[n-1] p[n-2] ... p[0] cin
            lookahead_carry =
                lookahead_carry |
                (propagate_chain & cin_in);

        end

    endfunction


    // ------------------------------------------------------------
    // All 64 carries
    // ------------------------------------------------------------

    genvar k;

    generate
        for (k = 1; k <= 64; k = k + 1) begin : gen_carries

            assign #(2) c[k] =
                lookahead_carry(p, g, cin, k);

        end
    endgenerate


    // ------------------------------------------------------------
    // Final carry
    // ------------------------------------------------------------

    assign cout = c[64];


    // ------------------------------------------------------------
    // Sum
    //
    // sum[0]  = p[0]  XOR cin
    // sum[1]  = p[1]  XOR c[1]
    // ...
    // sum[63] = p[63] XOR c[63]
    // ------------------------------------------------------------

    assign #(2) sum =
        p ^ {c[63:1], cin};

endmodule