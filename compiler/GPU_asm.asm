		NOP							# pc=0  : NOP
WAIT:   HALT                        # pc=1  : GPU_done → HIGH, PC frozen

        NOP                         # pc=2  : pipeline flush after HALT
        NOP                         # pc=3  : pipeline flush after HALT
        LW      $1, 0($0)           # pc=4  : $1 = Mem[0] — Vec1 (input A)
        LW      $2, 1($0)           # pc=5  : $2 = Mem[1] — Vec2 (weights B)
        LW      $6, 2($0)           # pc=6  : $6 = Mem[2] — Bias

        NOP                         # pc=7  : |
        NOP                         # pc=8  : | data hazard —
        NOP                         # pc=9  : | wait for LW
        NOP                         # pc=10 : | writeback
        NOP                         # pc=11 : |

        ACCUM   $7, $1, $2, $6      # pc=12 : $7 = ($1 × $2) + $6

        NOP                         # pc=13 : |
        NOP                         # pc=14 : | data hazard —
        NOP                         # pc=15 : | wait for ACCUM
        NOP                         # pc=16 : | writeback
        NOP                         # pc=17 : |

        RELU    $8, $7              # pc=18 : $8 = MAX(0, $7)

        NOP                         # pc=19 : |
        NOP                         # pc=20 : | 
        NOP                         # pc=21 : | wait for RELU writeback

        SW      $7, 3($0)           # pc=22 : Mem[3] = $7 — raw MAC result
        SW      $8, 4($0)           # pc=23 : Mem[4] = $8 — ReLU result

        NOP                         # pc=24 : branch setup buffer
        NOP                         # pc=25 : branch setup buffer

        BEQ     $0, $0, WAIT        # pc=26 : branch → pc=1 (HALT)
                                    #         offset = 1-27 = -26 → 0x2400FFE6

        NOP                         # pc=27 : branch delay slot
        NOP                         