// cla4.v

module cla4(
    input  [3:0] a,
    input  [3:0] b,
    input        cin,
    output [3:0] sum,
    output       cout
);

    wire p0, p1, p2, p3;
    wire g0, g1, g2, g3;

    wire c1, c2, c3;

    wire t1;
    wire t2, t3;
    wire t4, t5, t6;
    wire t7, t8, t9, t10;

    // Propagate signals
    xor #(2) (p0, a[0], b[0]);
    xor #(2) (p1, a[1], b[1]);
    xor #(2) (p2, a[2], b[2]);
    xor #(2) (p3, a[3], b[3]);

    // Generate signals
    and #(2) (g0, a[0], b[0]);
    and #(2) (g1, a[1], b[1]);
    and #(2) (g2, a[2], b[2]);
    and #(2) (g3, a[3], b[3]);

    // c1 = g0 + p0 cin
    and #(2) (t1, p0, cin);
    or  #(2) (c1, g0, t1);

    // c2 = g1 + p1 g0 + p1 p0 cin
    and #(2) (t2, p1, g0);
    and #(2) (t3, p1, p0, cin);
    or  #(2) (c2, g1, t2, t3);

    // c3 = g2 + p2 g1 + p2 p1 g0 + p2 p1 p0 cin
    and #(2) (t4, p2, g1);
    and #(2) (t5, p2, p1, g0);
    and #(2) (t6, p2, p1, p0, cin);
    or  #(2) (c3, g2, t4, t5, t6);

    // c4 = cout
    and #(2) (t7,  p3, g2);
    and #(2) (t8,  p3, p2, g1);
    and #(2) (t9,  p3, p2, p1, g0);
    and #(2) (t10, p3, p2, p1, p0, cin);

    or #(2) (cout, g3, t7, t8, t9, t10);

    // Sum bits
    xor #(2) (sum[0], p0, cin);
    xor #(2) (sum[1], p1, c1);
    xor #(2) (sum[2], p2, c2);
    xor #(2) (sum[3], p3, c3);

endmodule