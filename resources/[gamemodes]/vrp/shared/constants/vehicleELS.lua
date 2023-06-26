ELS_PRESET = {
    [596] = { -- LSPD / Police Cruiser
        hasSiren = true,
        headlightSequence = true,
        directionIndicator = {0.7, -1.9, 0.3}, -- sizeOffset, yOffset, zOffset
        sequenceCount = 4,
        sequenceDuration = 200,
        light = {
            --name = {x, y, z, size, r, g, b, [a]}
            r1 = {-0.75, -0.35, 0.95, 0.3, 200, 10, 0, 255},
            r2 = {-0.5, -0.35, 0.95, 0.3, 200, 10, 0},
            r3 = {-0.25, -0.35, 0.95, 0.3, 200, 10, 0, 0},
            b1 = {0.75, -0.35, 0.95, 0.3, 0, 50, 255, 0},
            b2 = {0.5, -0.35, 0.95, 0.3, 0, 50, 255, 0},
            b3 = {0.25, -0.35, 0.95, 0.3, 0, 50, 255, 0},
        },
        sequence = {
            [1] = {
				r1 = {alpha = 255},
				r2 = {alpha = 0},
				r3 = {alpha = 255},
				b1 = {alpha = 0},
				b2 = {alpha = 255},
				b3 = {alpha = 0},
                vehicle_light = {"d2", {200, 10, 0}},
            },
            [2] = {
				r1 = {alpha = 0},
				r2 = {alpha = 255},
				r3 = {alpha = 0},
				b1 = {alpha = 255},
				b2 = {alpha = 0},
				b3 = {alpha = 255},
            },
            [3] = {
				r1 = {alpha = 255},
				r2 = {alpha = 255},
				r3 = {alpha = 255},
				b1 = {alpha = 0},
				b2 = {alpha = 0},
				b3 = {alpha = 0},
                vehicle_light = {"d1", {0, 50, 255}},
            },
			[4] = {
				r1 = {alpha = 0},
				r2 = {alpha = 0},
				r3 = {alpha = 0},
				b1 = {alpha = 255},
				b2 = {alpha = 255},
				b3 = {alpha = 255},
			}
        },
    },
    [597] = { -- SFPD / Highway Patrol
        hasSiren = true,
        headlightSequence = true,
        directionIndicator = {0.7, -1.9, 0.3},
        sequenceCount = 4,
        sequenceDuration = 500,
        light = {
            --name = {x, y, z, size, r, g, b, [a]}
            r1 = {-0.75, -0.35, 0.95, 0.3, 200, 10, 0, 0},
            r2 = {-0.5, -0.35, 0.95, 0.3, 200, 10, 0, 0},
            r3 = {-0.25, -0.35, 0.95, 0.3, 200, 10, 0, 0},
            b1 = {0.75, -0.35, 0.95, 0.3, 0, 50, 255, 0},
            b2 = {0.5, -0.35, 0.95, 0.3, 0, 50, 255, 0},
            b3 = {0.25, -0.35, 0.95, 0.3, 0, 50, 255, 0},
            rf = {-0.6, 2.45,  0, 0.2, 255, 255, 255, 0},
            bf = {0.6, 2.45,  0, 0.2, 255, 255, 255, 0},
        },
        sequence = {
            [1] = {
                r1 = {strobe = false},
                r2 = {strobe = {100, 100, 255, 150}},
                r3 = {strobe = false},
                b1 = {strobe = {100, 100, 255, 150}},
                b2 = {strobe = false},
                b3 = {strobe = {100, 100, 255, 150}},
                rf = {strobe = {70, 70}},
                bf = {strobe = {70, 70}},
                vehicle_light = {"d2", {200, 10, 0}},
            },
            [2] = {
                r1 = {strobe = {100, 100, 255, 150}},
                r2 = {strobe = false},
                r3 = {strobe = {100, 100, 255, 150}},
                b1 = {strobe = false},
                b2 = {strobe = {100, 100, 255, 150}},
                b3 = {strobe = false},
                rf = {strobe = false},
                bf = {strobe = false},
				vehicle_light = {"d1", {0, 50, 255}},
            },
            [3] = {
                r1 = {strobe = false, alpha = 0},
                r2 = {strobe = false, alpha = 0},
                r3 = {strobe = false, alpha = 0},
                b1 = {strobe = {100, 100, 255, 150}},
                b2 = {strobe = {100, 100, 255, 150}},
                b3 = {strobe = {100, 100, 255, 150}},
				vehicle_light = {"d2", {200, 10, 0}},
            },
            [4] = {
                r1 = {strobe = {100, 100, 255, 150}},
                r2 = {strobe = {100, 100, 255, 150}},
                r3 = {strobe = {100, 100, 255, 150}},
                b1 = {strobe = false, alpha = 0},
                b2 = {strobe = false, alpha = 0},
                b3 = {strobe = false, alpha = 0},
				vehicle_light = {"d1", {0, 50, 255}},
            },
        },
    },
    [598] = { -- LVPD
        hasSiren = true,
        headlightSequence = true,
        directionIndicator = {0.6, -1.7, 0.4},
        sequenceCount = 4,
        sequenceDuration = 400,
        light = {
            --name = {x, y, z, size, r, g, b, [a]}
            r1 = {-0.75, -0.35, 0.95, 0.3, 200, 10, 0},
            r2 = {-0.5, -0.35, 0.95, 0.2, 200, 10, 0},
            r3 = {-0.25, -0.35, 0.95, 0.1, 200, 10, 0},
            b1 = {0.75, -0.35, 0.95, 0.4, 0, 50, 255},
            b2 = {0.5, -0.35, 0.95, 0, 0, 50, 255},
            b3 = {0.25, -0.35, 0.95, 0.2, 0, 50, 255},
            rf = {-0.4, 2.5,  0.05, 0, 200, 10, 0, 0},
            bf = {0.4, 2.5,  0.05, 0, 0, 50, 255, 0},
        },
        sequence = {
            [1] = {
                r1 = {blink = {0, 0.3, 400, 100}},
                r2 = {blink = {0.3, 0, 400, 100}},
                r3 = {blink = {0, 0.3, 400, 100}},
                b1 = {blink = {0.4, 0, 400, 100}},
                b2 = {blink = {0, 0.4, 400, 100}},
                b3 = {blink = {0.4, 0, 400, 100}},
                rf = {strobe = {70, 70}},
                bf = {strobe = {70, 70}},
				vehicle_light = {"d2", {200, 10, 0}},
            },
            [2] = {
                rf = {strobe = false},
                bf = {strobe = false},
            },
            [3] = {
				vehicle_light = {"d1", {0, 50, 255}},
            },
            [4] = {
            },
        },
    },
    [599] = { -- Police Ranger
        hasSiren = true,
        headlightSequence = true,
        sequenceCount = 2,
        sequenceDuration = 400,
        light = {
            --name = {x, y, z, size, r, g, b, [a]}
            r1 = {-0.4, 0.1, 1.15, 0.4, 200, 10, 0},
            r2 = {-0.7, 0.1, 1.15, 0.4, 200, 10, 0},
            b1 = {0.4, 0.1, 1.15, 0.4, 0, 50, 255},
            b2 = {0.7, 0.1, 1.15, 0.4, 0, 50, 255},
            bl = {-0.8, -2.5, 0.5, 0.3, 200, 10, 0, 0},
            br = {0.8, -2.5, 0.5, 0.3, 0, 50, 255, 0},
            fr = {0.9, 2.7, -0.45, 0.3, 255, 255, 255, 0},
            fl = {-0.9, 2.7, -0.45, 0.3, 255, 255, 255, 0},
        },
        sequence = {
            [1] = {
                r1 = {alpha = 0},
                r2 = {alpha = 255},
                b1 = {alpha = 255},
                b2 = {alpha = 0},
                vehicle_light = {"d2", {200, 10, 0}},
                fr = {strobe = false},
                fl = {strobe = false},
                bl = {strobe = false},
                br = {strobe = {100, 100, 255, 100}},
            },
            [2] = {
                r1 = {alpha = 255},
                r2 = {alpha = 0},
                b1 = {alpha = 0},
                b2 = {alpha = 255},
                vehicle_light = {"d1", {0, 50, 255}},
                fr = {strobe = {50, 50}},
                fl = {strobe = {50, 50}},
                br = {strobe = false},
                bl = {strobe = {100, 100, 255, 100}},
            },
        },
    },
    [523] = { -- Police Bike
        hasSiren = true,
        headlightSequence = true,
        sequenceCount = 2,
        sequenceDuration = 100,
        light = {},
        sequence = {
            [1] = {
                vehicle_light = {"d2", {200, 10, 0}},
            },
            [2] = {
                vehicle_light = {"d1", {0, 50, 255}},
            },
        },
    },
    ["LVPD_Orange"] = { -- LVPD
        hasSiren = true,
        headlightSequence = true,
        sequenceCount = 4,
        sequenceDuration = 300,
        light = {
            --name = {x, y, z, size, r, g, b, [a]}
            r1 = {-0.75, -0.35, 0.95, 0.3, 255, 150, 0},
            r2 = {-0.5, -0.35, 0.95, 0, 255, 150, 0},
            r3 = {-0.25, -0.35, 0.95, 0.3, 255, 150, 0},
            b1 = {0.75, -0.35, 0.95, 0, 255, 150, 0},
            b2 = {0.5, -0.35, 0.95, 0.3, 255, 150, 0},
            b3 = {0.25, -0.35, 0.95, 0, 255, 150, 0},
        },
        sequence = {
            [1] = {
                r1 = {fade = {0}},
                r2 = {fade = {0.3}},
                r3 = {fade = {0}},
                b1 = {fade = {0.3}},
                b2 = {fade = {0}},
                b3 = {fade = {0.3}},
				vehicle_light = {"d2", {255, 150, 0}},
            },
            [2] = {
                r1 = {fade = {0.3}},
                r2 = {fade = {0}},
                r3 = {fade = {0.3}},
                b1 = {fade = {0}},
                b2 = {fade = {0.3}},
                b3 = {fade = {0}},
				vehicle_light = {"d1", {255, 150, 0}},
            },
            [3] = {
                r1 = {fade = {0}},
                r2 = {fade = {0}},
                r3 = {fade = {0}},
                b1 = {fade = {0.3}},
                b2 = {fade = {0.3}},
                b3 = {fade = {0.3}},
				vehicle_light = {"d2", {255, 150, 0}},
            },
            [4] = {
                r1 = {fade = {0.3}},
                r2 = {fade = {0.3}},
                r3 = {fade = {0.3}},
                b1 = {fade = {0}},
                b2 = {fade = {0}},
                b3 = {fade = {0}},
				vehicle_light = {"d1", {255, 150, 0}},
            },
        },
    },
    [433] = { -- Barracks
        sequenceCount = 2,
        --lightBar = {0, 1.3, 1.75, 1.2, "orange"},
        sequenceDuration = 400,
        hasSiren = true,
        headlightSequence = true,
        light = {
            --[[r2 = {-0.8, 1.3, 1.8, 0, 255, 145, 0},
            r3 = {-0.5, 1.3, 1.8, 0, 255, 145, 0},
            b2 = {0.8, 1.3, 1.8, 0, 255, 145, 0},
            b3 = {0.5, 1.3, 1.8, 0, 255, 145, 0},]]
            back = {-0.65, -4.5, -0.35, 0, 255, 145, 0},
        },
        sequence = {
            [1] = {
                --[[r2 = {fade = {0.3}},
                r3 = {fade = {0}},
                b2 = {fade = {0}},
                b3 = {fade = {0.3}},]]
                back = {fade = {0.5}},
                vehicle_light = {"d1", {255, 145, 0}},
            },
            [2] = {
                --[[r2 = {fade = {0}},
                r3 = {fade = {0.3}},
                b2 = {fade = {0.3}},
                b3 = {fade = {0}},]]
                back = {fade = {0}},
                vehicle_light = {"d2", {255, 145, 0}},
            }
        },
    },
    ["Patriot_Orange"] = { -- Patriot
		sequenceCount = 2,
		sequenceDuration = 400,
		hasSiren = true,
		headlightSequence = true,
		light = {
			y = {0.65, 0.7, 0.5, 0, 255, 145, 0},
		},
		sequence = {
			[1] = {
				y = {fade = {0.3}},
				vehicle_light = {"d2", {255, 145, 0}},
			},
			[2] = {
				y = {fade = {0}},
				vehicle_light = {"d1", {255, 145, 0}},
			}
		},
	},
    ["FBI_Buffalo"] = { --FBI Buffalo
        hasSiren = true,
        headlightSequence = true,
        sequenceCount = 4,
        sequenceDuration = 250,
        light = {
            fbu = {0.5, -2, 0.3, 0.25, 0, 50, 255, 0}, --front blue up
            fbd = {0.6, 0.7, 0.25, 0.25, 0, 50, 255, 0}, --fb down
            fru = {-0.5, -2, 0.3, 0.2, 200,10, 0, 0},
            frd = {0.3, 0.7, 0.25, 0.2, 200,10, 0, 0},
            fb = {0.4, 2.6, -0.35, 0.25, 0, 50, 255, 0}, --side blue
            fr = {-0.4, 2.6, -0.35, 0.2, 200,10, 0, 0},

        },
        sequence = {
            [1] = {
                fbu = {strobe = false},
                fru = {strobe = {70, 70, 255, 150}},
                fb = {strobe = {50, 50}},
                vehicle_light = {"l", {200, 10, 0}},
            },
            [2] = {
				frd = {strobe = false},
				fbd = {strobe = {70, 70, 255, 150}},
                fb = {strobe = false},
                fr = {strobe = {50, 50}},
                vehicle_light = {"r", {0, 50, 255}},
            },
            [3] = {
                fru = {strobe = false},
                fbu = {strobe = {70, 70, 255, 150}},
                fr = {strobe = false},
                vehicle_light = {"l", {200, 10, 0}},
            },
            [4] = {
				frd = {strobe = {70, 70, 255, 150}},
                fbd = {strobe = false},
                vehicle_light = {"r", {0, 50, 255}},
            },
        }
    },
    ["FBI_Washington"] = { --FBI Washington
        hasSiren = true,
        headlightSequence = true,
        sequenceCount = 2,
        sequenceDuration = 250,
        light = {
            fb = {0.5, 0.9, 0.2, 0.25, 0, 50, 255, 0},
            fr = {0.2, 0.9, 0.2, 0.25, 200,10, 0, 0},

        },
        sequence = {
            [1] = {
                fr = {strobe = false},
                fb = {strobe = {70, 70, 255, 150}},
                vehicle_light = {"l", {200, 10, 0}},
            },
            [2] = {
                fr = {strobe = {70, 70, 255, 150}},
                fb = {strobe = false},
				vehicle_light = {"r", {0, 50, 255}},

            },
        }
    },
    ["FBI_Premier"] = { --FBI Premier
        hasSiren = true,
        headlightSequence = true,
        sequenceCount = 4,
        sequenceDuration = 250,
        light = {
            bb = {0.5, -1.9, 0.35, 0.25, 0, 50, 255, 0},
            fb = {0.1, 0.4, 0.7, 0.25, 0, 50, 255, 0},
            br = {-0.5, -1.9, 0.35, 0.25, 200,10, 0, 0},
            fr = {-0.1, 0.4, 0.7, 0.25, 200,10, 0, 0},

        },
        sequence = {
            [1] = {
                bb = {strobe = false},
                br = {strobe = {70, 70, 255, 150}},
                vehicle_light = {"l", {200, 10, 0}},
            },
            [2] = {
                fr = {strobe = false},
                fb = {strobe = {70, 70, 255, 150}},
                vehicle_light = {"r", {0, 50, 255}},
            },
            [3] = {
                br = {strobe = false},
                bb = {strobe = {70, 70, 255, 150}},
                vehicle_light = {"l", {200, 10, 0}},
            },
            [4] = {
                fr = {strobe = {70, 70, 255, 150}},
                fb = {strobe = false},
                vehicle_light = {"r", {0, 50, 255}},
            },
        }
    },
    ["FBI_Elegant"] = { --FBI Elegant
        hasSiren = true,
        headlightSequence = true,
        sequenceCount = 2,
        sequenceDuration = 400,
        light = {
            bb = {0.45, -3.1, -0.05, 0.2, 255, 255, 255, 0},
            fb = {0.1, 0.3, 0.7, 0.25, 0, 50, 255, 0},
            br = {-0.45, -3.1, -0.05, 0.2, 255, 255, 255, 0},
            fr = {-0.1, 0.3, 0.7, 0.25, 200,10, 0, 0},

        },
        sequence = {
            [1] = {
                bb = {strobe = false},
                br = {strobe = false},
				fr = {strobe = false},
                fb = {strobe = {70, 70, 255, 150}},
                vehicle_light = {"l", {200, 10, 0}},
            },
            [2] = {

				br = {strobe = {100, 100}},
                bb = {strobe = {100, 100}},
				fr = {strobe = {70, 70, 255, 150}},
                fb = {strobe = false},
				vehicle_light = {"r", {0, 50, 255}},
            },
        }
    },
    ["FBI_Sultan"] = { --FBI Sultan
        hasSiren = true,
        headlightSequence = true,
        sequenceCount = 4,
        sequenceDuration = 250,
        light = {
            f1 = {0.75, 2.6, -0.2, 0.25, 255, 255, 255, 0}, --front blue up
            f2 = {-0.75, 2.6, -0.2, 0.25, 255, 255, 255, 0},
            sb = {-0.15, 0.5, 0.7, 0.25, 0, 50, 255, 0}, --side blue
            sr = {0.15, 0.5, 0.7, 0.25, 200,10, 0, 0},
            br = {-0.5, -1.6, 0.4, 0.25, 200, 10, 0, 0},
            bb = {0.5, -1.6, 0.4, 0.25, 0, 50, 255, 0},
        },
        sequence = {
            [1] = {
                sr = {color={0,50,255,255}},
				vehicle_light = {"d2", {200, 10, 0}},
				f1 = {strobe = {50, 500}},
				f2 = {strobe = {50, 500}},
				br = {strobe = {50, 50, 255, 150}},
				bb = {strobe = false},
            },
			[2] = {

				sr = {strobe = false, alpha=0},
				sb = {strobe = {50, 50}, color={0, 50, 255,255}},

				f1 = {strobe = false},
				f2 = {strobe = false},
			},
            [3] = {
				bb = {strobe = {50, 50, 255, 150}},
				br = {strobe = false},
                sb = {color={200, 10, 0}},
				vehicle_light = {"d1", {0, 50, 255}},
            },
			[4] = {


				sr = {strobe = {50, 50}, color={200, 10, 0, 255}},
				sb = {strobe = false, alpha=0},
			},
        }
    },
    [490] = { --FBI Rancher
        hasSiren = true,
        headlightSequence = true,
        sequenceCount = 4,
        sequenceDuration = 250,
        light = {
            fbu = {0.5, 3.2, 0.1, 0.25, 0, 50, 255, 0}, --front blue up
            fbd = {0.5, 3.2, -0.1, 0.25, 0, 50, 255, 0}, --fb down
            fru = {-0.5, 3.2, 0.1, 0.2, 200,10, 0, 0},
            frd = {-0.5, 3.2, -0.1, 0.2, 200,10, 0, 0},
            sb = {1.1, -1.3, 0.4, 0.25, 0, 50, 255, 0}, --side blue
            sr = {-1.1, -1.3, 0.4, 0.2, 200,10, 0, 0},
            bb1 = {0.3, -2.8, 0.8, 0.2, 0, 50, 255, 0}, --back blue
            bb2 = {0.6, -2.8, 0.8, 0.2, 0, 50, 255, 0},
            br1 = {-0.3, -2.8, 0.8, 0.2, 200, 10, 0, 0},
            br2 = {-0.6, -2.8, 0.8, 0.2, 200, 10, 0, 0},
        },
        sequence = {
            [1] = {
                fbu = {strobe = false},
                frd = {strobe = false},
                fru = {strobe = {70, 70, 255, 150}},
                fbd = {strobe = {70, 70, 255, 150}},
				sr = {strobe = false, alpha=0},
				sb = {strobe = {50, 50}, color={0, 50, 255,255}},
                bb2 = {alpha = 255},
				br1 = {alpha = 0},
				vehicle_light = {"d2", {200, 10, 0}},
            },
			[2] = {
				sb = {color={200, 10, 0}},
				br2 = {alpha = 255},
				bb2 = {alpha = 0},
			},
            [3] = {
                fru = {strobe = false},
                fbd = {strobe = false},
                fbu = {strobe = {70, 70, 255, 150}},
                frd = {strobe = {70, 70, 255, 150}},
                sr = {strobe = {50, 50}, color={200, 10, 0, 255}},
				sb = {strobe = false, alpha=0},
				bb1 = {alpha = 255},
				br2 = {alpha = 0},
				vehicle_light = {"d1", {0, 50, 255}},

            },
			[4] = {
				sr = {color={0,50,255,255}},
				br1 = {alpha = 255},
				bb1 = {alpha = 0},
			},
        }
    },
    [601] = { --SWAT Tank
        hasSiren = true,
        headlightSequence = true,
        sequenceCount = 2,
        sequenceDuration = 300,
        light = {

            fr = {-1.2, 2.1, 0.97, 0.3, 200, 10, 0, 0},
            fb = {1.2, 2.1, 0.97, 0.3, 0, 50, 255, 0},
            sr = {-1, 0, 0, 0.4, 200, 10, 0},
            sb = {1, 0, 0, 0.4, 200, 10, 0},
            br = {-1, -3, 1.15, 0.3, 200, 10, 0, 0},
            bb = {1, -3, 1.15, 0.3, 0, 50, 255, 0},
        },
        sequence = {
            [1] = {
                vehicle_light = {"l", {200, 10, 0}},
                fr = {strobe = {100, 100, 255, 100}},
                bb = {strobe = {100, 100, 255, 100}},
                fb = {strobe = false},
                br = {strobe = false},
                sr = {strobe = {50, 50, 255, 100}, color = {200, 10, 0}},
                sb = {strobe = {50, 50, 255, 100}, color = {0, 50, 255}},
            },
            [2] = {
                vehicle_light = {"r", {0, 50, 255}},
                fb = {strobe = {100, 100, 255, 100}},
                br = {strobe = {100, 100, 255, 100}},
                fr = {strobe = false},
                bb = {strobe = false},
                sb = {color = {200, 10, 0}},
                sr = { color = {0, 50, 255}},
            },
        }
    },
    [427] = { --Enforcer
        hasSiren = true,
        headlightSequence = true,
        sequenceCount = 6,
        sequenceDuration = 250,
        light = {
            -- top front
            tfr = {0.4, 1.1, 1.45, 0.4, 255, 0 ,0}, --top front right
            tfl = {-0.4, 1.1, 1.45, 0, 200, 10, 0}, --top front left
            tfm = {0, 1.1, 1.45, 0.4, 255, 145, 0, 0}, --middle
            --side yellow
            sr1 = {1.2, 0.1, 1.25, 0.25, 255, 145, 0}, --side right
            sr2 = {1.2, -1.6, 1.25, 0, 255, 145, 0},
            sr3 = {1.2, -3.4, 1.25, 0.25, 255, 145, 0},
            sl1 = {-1.2, 0.1, 1.25, 0, 255, 145, 0}, --side left
            sl2 = {-1.2, -1.6, 1.25, 0.25, 255, 145, 0},
            sl3 = {-1.2, -3.4, 1.25, 0, 255, 145, 0},
            --back
            br = {0.95, -3.8, 1.3, 0.25, 255, 255, 255, 0}, --side right
            bl = {-0.95, -3.8, 1.3, 0.25, 255, 255, 255, 0},
        },
        sequence = {
        	[1] = {
				tfr = {fade = {0}},
                tfl = {fade = {0.4}},
				sr1 = {blink = {0, 0.4, 400, 50}},
				sr2 = {blink = {0, 0.4, 400, 50}},
                sr3 = {blink = {0, 0.4, 400, 50}},
                sl1 = {blink = {0, 0.4, 400, 50}},
				sl2 = {blink = {0, 0.4, 400, 50}},
				sl3 = {blink = {0, 0.4, 400, 50}},
				br = {strobe = false},
				bl = {strobe = false},
				tfm = {strobe = false},
				vehicle_light = {"d2", {200, 10, 0}},

			},
			[2] = {
				tfr = {fade = {0.4}},
                tfl = {fade = {0}},
				vehicle_light = {"d1", {200, 10, 0}},
			},
			[3] = {
				tfr = {fade = {0}},
                tfl = {fade = {0.4}},
				br = {strobe = {50, 50, 255, 150}},
				bl = {strobe = {50, 50, 255, 150}},
				tfm = {strobe = {50, 50, 255, 150}},
				vehicle_light = {"full", {255, 145, 0}},
			},
			[4] = {
				br = {strobe = false},
				bl = {strobe = false},
				tfm = {strobe = false},
				tfr = {fade = {0.4}},
                tfl = {fade = {0}},
				vehicle_light = {"d1", {200, 10, 0}},
			},
			[5] = {
				tfr = {fade = {0}},
                tfl = {fade = {0.4}},
				vehicle_light = {"d2", {200, 10, 0}},
			},
			[6] = {
				tfr = {fade = {0.4}},
                tfl = {fade = {0}},
				br = {strobe = {50, 50, 255, 150}},
				bl = {strobe = {50, 50, 255, 150}},
				tfm = {strobe = {50, 50, 255, 150}},
				vehicle_light = {"full", {255, 145, 0}},
			},
        }
    },
    [528] = { --FBI Truck
        hasSiren = true,
        headlightSequence = true,
        lightBar = {0, 0, 1.1},
        sequenceCount = 2,
        sequenceDuration = 500,
        light = {
            fbu = {0.45,    2.55,   0,    0.25,    0,  50, 255, 0},
            fbd = {0.45,    2.55,   -0.3,   0.25,    0,  50, 255, 0},
            fru = {-0.45,   2.55,   0,    0.2, 200, 10, 0,   0},
            frd = {-0.45,   2.55,   -0.3,   0.2, 200, 10, 0,   0},
			r2 = {-0.6, 0, 1.15, 0, 200, 10, 0},
            r3 = {-0.3, 0, 1.15, 0.4, 200, 10, 0},
            b2 = {0.6, 0, 1.15, 0.4, 0, 50, 255},
            b3 = {0.3, 0, 1.15, 0, 0, 50, 255},
        },
        sequence = {
            [1] = {
                fbu = {strobe = false},
                frd = {strobe = false},
                fru = {strobe = {100, 100, 255, 100}},
                fbd = {strobe = {100, 100, 255, 100}},
				r2 = {fade = {0.4}},
				r3 = {fade = {0}},
				b2 = {fade = {0}},
				b3 = {fade = {0.4}},
                vehicle_light = {"l", {200, 10, 0}},
            },
            [2] = {
                fru = {strobe = false},
                fbd = {strobe = false},
                fbu = {strobe = {100, 100, 255, 100}},
                frd = {strobe = {100, 100, 255, 100}},
				r2 = {fade = {0}},
				r3 = {fade = {0.4}},
				b2 = {fade = {0.4}},
				b3 = {fade = {0}},
				vehicle_light = {"r", {0, 50, 255}},
            },
        }
    },
    [407] = { --Fire Truck
        hasSiren = true,
        headlightSequence = true,
        sequenceCount = 4,
        sequenceDuration = 300,
        light = {
            uw = {0, 3.3, 1.35, 0.5, 255, 255, 255, 0},
            urr = {0.65, 3.3, 1.35, 0, 255, 10, 0},
            url = {-0.65, 3.3, 1.35, 0.4, 255, 10, 0},
            frr = {0.7, 4.15, 0.06, 0.2, 255, 10, 0},
			frl = {-0.7, 4.15, 0.06, 0, 255, 10, 0},
			fyr = {0.3, 4.45, -0.65, 0.2, 255, 145, 0, 0},
			fyl = {-0.3, 4.45, -0.65, 0.2, 255, 145, 0, 0},
			byr = {0.4, -3.35, 0.4, 0, 255, 145, 0},
			bym = {0, -3.35, 0.4, 0.4, 255, 145, 0},
			byl = {-0.4, -3.35, 0.4, 0, 255, 145, 0},
        },
        sequence = {
            [1] = {
				uw = {strobe = {80, 80}},
				urr = {fade = {0.4}},
          		url = {fade = {0}},
				byr = {fade = {0.3}},
				bym = {fade = {0}},
				byl = {fade = {0.3}},
            },
            [2] = {
				uw = {strobe = false},
           		urr = {fade = {0}},
           		url = {fade = {0.4}},
				frr = {fade = {0}},
                frl = {fade = {0.2}},
				fyr = {strobe = {100, 100, 255, 100}},
                fyl = {strobe = false},
                vehicle_light = {"d1", {255, 10, 0}},
            },
            [3] = {
				urr = {fade = {0.4}},
          		url = {fade = {0}},
				byr = {fade = {0}},
				bym = {fade = {0.4}},
				byl = {fade = {0}},
            },
            [4] = {
				urr = {fade = {0}},
           		url = {fade = {0.4}},
				frr = {fade = {0.2}},
				frl = {fade = {0}},
				fyr = {strobe = false},
                fyl = {strobe = {100, 100, 255, 100}},
                vehicle_light = {"d2", {255, 10, 0}},
            },
        }
    },
    [544] = { --Fire Truck Ladder
        hasSiren = true,
        headlightSequence = true,
        sequenceCount = 4,
        sequenceDuration = 400,
        light = {
            tfry = {0.95, 2, 1.45, 0, 255, 145, 0},
            tfly = {-0.95, 2, 1.45, 0.4, 255, 145, 0},
            tbry = {0.95, 2.75, 1.45, 0.4, 255, 145, 0},
            tbly = {-0.95, 2.75, 1.45, 0, 255, 145, 0},
            frr = {0.65, 3.6, 0.06, 0, 200, 10, 0},
            flr = {-0.65, 3.6, 0.06, 0.2, 200, 10, 0},
            bry = {0.9, -4.2, -0.85, 0.2, 255, 145, 0, 0},
            bly = {-0.9, -4.2, -0.85, 0.2, 255, 145, 0, 0},
        },
        sequence = {
            [1] = {
                vehicle_light = {"d1", {255, 10, 0}},
                tfry = {blink = {0, 0.4, 400, 50}},
                tfly = {blink = {0, 0.4, 400, 50}},
                tbry = {blink = {0, 0.4, 400, 50}},
                tbly = {blink = {0, 0.4, 400, 50}},
                frr = {fade = {0.2}},
                flr = {fade = {0}},
            },
            [2] = {
                vehicle_light = {"d2", {255, 10, 0}},
                bry = {strobe = {100, 100, 255, 100}},
                bly = {strobe = false},
            },
            [3] = {
                vehicle_light = {"d1", {255, 145, 0}},
                frr = {fade = {0}},
                flr = {fade = {0.2}},
            },
            [4] = {
                vehicle_light = {"d2", {255, 145, 0}},
                bly = {strobe = {100, 100, 255, 100}},
                bry = {strobe = false},
            },
        }
    },
    [416] = { --Ambulance
        hasSiren = true,
        headlightSequence = true,
        sequenceCount = 2,
        sequenceDuration = 250,
        light = {
            tw = {0, 0.9, 1.3, 0.5, 255, 255, 255, 0},
            trr = {0.5, 0.9, 1.3, 0.3, 255, 10, 0, 0},
            tlr = {-0.5, 0.9, 1.3, 0.3, 255, 10, 0, 0},
            brr = {1.25, -3.4, 1.45, 0, 255, 10, 0},
            blr = {-1.25, -3.4, 1.45, 0.4, 255, 10, 0},
			bry = {0.4, -3.65, 1.5, 0.2, 255, 145, 0, 0},
            bly = {-0.4, -3.65, 1.5, 0.2, 255, 145, 0, 0},
        },
        sequence = {
            [1] = {
                vehicle_light = {"d1", {255, 10, 0}},
				brr = {fade = {0.4}},
				blr = {fade = {0}},
				tw = {strobe = {50, 50}},
				trr = {strobe = false},
           	 	tlr = {strobe = false},
				bry = {strobe = {100, 100, 255, 100}},
                bly = {strobe = false},
            },
            [2] = {
                vehicle_light = {"d2", {255, 10, 0}},
				brr = {fade = {0}},
				blr = {fade = {0.4}},
				tw = {strobe = false},
				trr = {strobe = {100, 100, 255, 100}},
           	 	tlr = {strobe = {100, 100, 255, 100}},
				bly = {strobe = {100, 100, 255, 100}},
                bry = {strobe = false},
            },
        }
    },
    ["LVPD_Red"] = { -- LVPD
        hasSiren = true,
        headlightSequence = true,
        directionIndicator = {0.6, -1.7, 0.4},
        sequenceCount = 4,
        sequenceDuration = 350,
        light = {
            --name = {x, y, z, size, r, g, b, [a]}
            r1 = {-0.75, -0.35, 0.95, 0.3, 255, 10, 0},
            r2 = {-0.5, -0.35, 0.95, 0, 255, 10, 0},
            r3 = {-0.25, -0.35, 0.95, 0.3, 255, 10, 0},
            b1 = {0.75, -0.35, 0.95, 0, 255, 10, 0},
            b2 = {0.5, -0.35, 0.95, 0.3, 255, 10, 0},
            b3 = {0.25, -0.35, 0.95, 0, 255, 10, 0},
            rf = {-0.4, 2.5,  0.05, 0.3, 255, 145, 0, 0},
            bf = {0.4, 2.5,  0.05, 0.3, 255, 145, 0, 0},
        },
        sequence = {
            [1] = {
                r1 = {fade = {0}},
                r2 = {fade = {0.3}},
                r3 = {fade = {0}},
                b1 = {fade = {0.3}},
                b2 = {fade = {0}},
                b3 = {fade = {0.3}},
                rf = {strobe = {90, 90}},
                bf = {strobe = {90, 90}},
                vehicle_light = {"d2", {255, 10, 0}},
            },
            [2] = {
                r1 = {fade = {0.3}},
                r2 = {fade = {0}},
                r3 = {fade = {0.3}},
                b1 = {fade = {0}},
                b2 = {fade = {0.3}},
                b3 = {fade = {0}},
                rf = {strobe = false},
                bf = {strobe = false},
                vehicle_light = {"d1", {255, 10, 0}},
            },
            [3] = {
                r1 = {fade = {0}},
                r2 = {fade = {0}},
                r3 = {fade = {0}},
                b1 = {fade = {0.3}},
                b2 = {fade = {0.3}},
                b3 = {fade = {0.3}},
                vehicle_light = {"d2", {255, 10, 0}},
            },
            [4] = {
                r1 = {fade = {0.3}},
                r2 = {fade = {0.3}},
                r3 = {fade = {0.3}},
                b1 = {fade = {0}},
                b2 = {fade = {0}},
                b3 = {fade = {0}},
                vehicle_light = {"d1", {255, 10, 0}},
            },
        },
    },
    ["LSPD_Red"] = { -- Rescue Cruiser
        hasSiren = true,
        headlightSequence = true,
        directionIndicator = {0.7, -1.9, 0.3},
		sequenceCount = 4,
		sequenceDuration = 200,
		light = {
			--name = {x, y, z, size, r, g, b, [a]}
			r1 = {-0.75, -0.35, 0.95, 0.3, 255, 10, 0, 255},
			r2 = {-0.5, -0.35, 0.95, 0.3, 255, 10, 0},
			r3 = {-0.25, -0.35, 0.95, 0.3, 255, 10, 0, 0},
			b1 = {0.75, -0.35, 0.95, 0.3, 255, 10, 0, 0},
			b2 = {0.5, -0.35, 0.95, 0.3, 255, 10, 0, 0},
			b3 = {0.25, -0.35, 0.95, 0.3, 255, 10, 0, 0},
			w = {0, -0.35, 0.95, 0.4, 255, 255, 255, 0},
		},
		sequence = {
			[1] = {
				r1 = {alpha = 0},
				r2 = {alpha = 0},
				r3 = {alpha = 0},
				b2 = {alpha = 255},
				w = {strobe = false},
				vehicle_light = {"d2", {255, 10, 0}},
			},
			[2] = {
				r3 = {alpha = 255},
				b1 = {alpha = 255},
			},
			[3] = {
				r2 = {alpha = 255},
				b1 = {alpha = 0},
				b2 = {alpha = 0},
				b3 = {alpha = 0},
				vehicle_light = {"d1", {255, 10, 0}},
			},
			[4] = {
				r1 = {alpha = 255},
				b3 = {alpha = 255},
				w = {strobe = {50, 50, 255, 100}},
			}
		},
    },
    ["Ranger_Red"] = { -- Rescue Ranger
        hasSiren = true,
        headlightSequence = true,
        sequenceCount = 2,
        sequenceDuration = 400,
        light = {
            --name = {x, y, z, size, r, g, b, [a]}
            r1 = {-0.4, 0.1, 1.15, 0.4, 255, 10, 0},
            r2 = {-0.7, 0.1, 1.15, 0.4, 255, 10, 0},
            b1 = {0.4, 0.1, 1.15, 0.4, 255, 10, 0},
            b2 = {0.7, 0.1, 1.15, 0.4, 255, 10, 0},
            bl = {-0.8, -2.5, 0.5, 0.3, 255, 145, 0, 0},
            br = {0.8, -2.5, 0.5, 0.3, 255, 145, 0, 0},
            fr = {0.9, 2.7, -0.45, 0.3, 255, 255, 255, 0},
            fl = {-0.9, 2.7, -0.45, 0.3, 255, 255, 255, 0},
        },
        sequence = {
            [1] = {
                r1 = {alpha = 0},
                r2 = {alpha = 255},
                b1 = {alpha = 255},
                b2 = {alpha = 0},
                vehicle_light = {"d2", {255, 10, 0}},
                fr = {strobe = false},
                fl = {strobe = false},
                bl = {strobe = false},
                br = {strobe = {100, 100, 255, 100}},
            },
            [2] = {
                r1 = {alpha = 255},
                r2 = {alpha = 0},
                b1 = {alpha = 0},
                b2 = {alpha = 255},
                vehicle_light = {"d1", {255, 10, 0}},
                fr = {strobe = {50, 50}},
                fl = {strobe = {50, 50}},
                br = {strobe = false},
                bl = {strobe = {100, 100, 255, 100}},
            },
        },
    },
    ["Rescue_Moonbeam"] = {
        hasSiren = true,
        headlightSequence = true,
		lightBar = {0, 0.7, 1.03, 1.05, "red"},
        sequenceCount = 2,
        sequenceDuration = 300,
        light = {
            r1 = {-0.7, 0.7, 1.1, 0.3, 255, 10, 0},
            r3 = {-0.3, 0.7, 1.1, 0.3, 255, 10, 0},
            w = {0, 0.7, 1.1, 0.4, 255, 255, 255, 0},
            b1 = {0.7, 0.7, 1.1, 0.3, 255, 10, 0},
            b3 = {0.3, 0.7, 1.1, 0.3, 255, 10, 0},
			y1 = {0.7, -2.25, 0.8, 0.2, 255, 145, 0, 0},
			y2 = {-0.7, -2.25, 0.8, 0.2, 255, 145, 0, 0},
        },
        sequence = {
            [1] = {
				b1 = {strobe = {150, 150, 255, 0}},
				r1 = {strobe = {150, 150, 255, 0}},
				r3 = {strobe = {100, 100, 255, 100}},
                b3 = {strobe = {100, 100, 255, 100}},
                w = {strobe = false},
                y1 = {strobe = {100, 50, 255, 100}},
				y2 = {strobe = false},
				vehicle_light = {"l", {255, 10, 0}},
            },
            [2] = {
				r3 = {strobe = {150, 150, 255, 0}},
				b3 = {strobe = {150, 150, 255, 0}},
				b1 = {strobe = {100, 100, 255, 100}},
                r1 = {strobe = {100, 100, 255, 100}},
				w = {strobe = {100, 50, 255, 0}},
				y1 = {strobe = false},
				y2 = {strobe = {100, 50, 255, 100}},
				vehicle_light = {"r", {255, 10, 0}},
            }
        },
    },
    [525] = { --Towtruck
        sequenceCount = 1,
        sequenceDuration = 1000,
        light = {
            r1 = {0.55, -0.45, 1.45, 0, 200, 10, 0},
            r2 = {-0.55, -0.45, 1.45, 0.4, 255, 10, 0},
            y1 = {0.15, -0.45, 1.45, 0, 255, 145, 0},
            y2 = {-0.15, -0.45, 1.45, 0.4, 255, 145, 0},
        },
        sequence = {
            [1] = {
                r1 = {blink = {0, 0.4, 400, 50}},
                r2 = {blink = {0.4, 0, 400, 50}},
                y1 = {blink = {0, 0.4, 400, 50}},
                y2 = {blink = {0.4, 0, 400, 50}},
            },
        },
    },
    ["Fuel_Van"] = { --Utility Van
        sequenceCount = 2,
        lightBar = {0, 0.7, 1.35, 1.1, "orange"},
        sequenceDuration = 400,
        light = {
            r2 = {-0.7, 0.7, 1.4, 0, 255, 145, 0},
            r3 = {-0.4, 0.7, 1.4, 0, 255, 145, 0},
            b2 = {0.7, 0.7, 1.4, 0, 255, 145, 0},
            b3 = {0.4, 0.7, 1.4, 0, 255, 145, 0},
        },
        sequence = {
            [1] = {
				r2 = {fade = {0.3}},
				r3 = {fade = {0}},
				b2 = {fade = {0}},
				b3 = {fade = {0.3}},
            },
            [2] = {
				r2 = {fade = {0}},
				r3 = {fade = {0.3}},
				b2 = {fade = {0.3}},
				b3 = {fade = {0}},
            }
        },
    },
    ["Newsvan_DI"] = { --News Van
        sequenceCount = 2,
        sequenceDuration = 400,
        directionIndicator = {0.7, -3.1, 1.2},
        light = {
            top = {0, -0.55, 1.75, 0, 255, 10, 0},
        },
        sequence = {
            [1] = {
                top = {fade = {0.1, 100}},
            },
            [2] = {
                top = {fade = {0.0}},
            },
        },
    },

    ["Police_Huntley"] = { --SASF Huntley
        hasSiren = true,
        headlightSequence = true,
        directionIndicator = {0.7, -2.5, 1.1},
        lightBar = {0, -0.55, 1.3, 1.1},
        sequenceCount = 2,
        sequenceDuration = 500,
        light = {
            r1 = {-0.75, -0.55, 1.35, 0.4, 200, 10, 0, 0},
            r2 = {-0.5, -0.55, 1.35, 0.4, 200, 10, 0, 0},
            r3 = {-0.25, -0.55, 1.35, 0.4, 200, 10, 0, 0},
            b1 = {0.75, -0.55, 1.35, 0.4, 0, 50, 255, 0},
            b2 = {0.5, -0.55, 1.35, 0.4, 0, 50, 255, 0},
            b3 = {0.25, -0.55, 1.35, 0.4, 0, 50, 255, 0},
        },
        sequence = {
            [1] = {
				r1 = {strobe = false},
				r2 = {strobe = {100, 100, 255, 100}},
				r3 = {strobe = false},
				b1 = {strobe = {100, 100, 255, 100}},
				b2 = {strobe = false},
				b3 = {strobe = {100, 100, 255, 100}},
                vehicle_light = {"l", {200, 10, 0}},
            },
            [2] = {
				r1 = {strobe = {100, 100, 255, 100}},
				r2 = {strobe = false},
				r3 = {strobe = {100, 100, 255, 100}},
				b1 = {strobe = false},
				b2 = {strobe = {100, 100, 255, 100}},
				b3 = {strobe = false},
				vehicle_light = {"r", {0, 50, 255}},
            }
        },
    },
    ["Police_Bobcat"] = { --SASF Pickup
        hasSiren = true,
        headlightSequence = true,
        lightBar = {0, 0, 0.85},
        sequenceCount = 2,
        sequenceDuration = 400,
        light = {
            r2 = {-0.6, 0, 0.9, 0, 200, 10, 0},
            r3 = {-0.3, 0, 0.9, 0.4, 200, 10, 0},
            b2 = {0.6, 0, 0.9, 0.4, 0, 50, 255},
            b3 = {0.3, 0, 0.9, 0, 0, 50, 255},
        },
        sequence = {
            [1] = {
				r2 = {fade = {0.4}},
				r3 = {fade = {0}},
				b2 = {fade = {0}},
				b3 = {fade = {0.4}},
                vehicle_light = {"l", {200, 10, 0}},
            },
            [2] = {
				r2 = {fade = {0}},
				r3 = {fade = {0.4}},
				b2 = {fade = {0.4}},
				b3 = {fade = {0}},
				vehicle_light = {"r", {0, 50, 255}},
            }
        },
    },
    ["Police_Burrito"] = { --SASF Van
        hasSiren = true,
        headlightSequence = true,
		lightBar = {0, 0.7, 0.95},
        sequenceCount = 2,
        sequenceDuration = 300,
        light = {
            r1 = {-0.75, 0.7, 1, 0.3, 200, 10, 0},
            r2 = {-0.5, 0.7, 1, 0.3, 200, 10, 0},
            r3 = {-0.25, 0.7, 1, 0.3, 200, 10, 0},
            b1 = {0.75, 0.7, 1, 0.3, 0, 50, 255},
            b2 = {0.5, 0.7, 1, 0.3, 0, 50, 255},
            b3 = {0.25, 0.7, 1, 0.3, 0, 50, 255},
        },
        sequence = {
            [1] = {
				r1 = {alpha = 0},
				r2 = {alpha = 255},
				r3 = {alpha = 0},
				b1 = {alpha = 255},
				b2 = {alpha = 0},
				b3 = {alpha = 255},
                vehicle_light = {"l", {200, 10, 0}},
            },
            [2] = {
				r1 = {alpha = 255},
				r2 = {alpha = 0},
				r3 = {alpha = 255},
				b1 = {alpha = 0},
				b2 = {alpha = 255},
				b3 = {alpha = 0},
				vehicle_light = {"r", {0, 50, 255}},
            }
        },
    },
    ["Police_Sultan"] = { --Police Sultan
        hasSiren = true,
        headlightSequence = true,
		lightBar = {0, -0.27, 0.87},
		directionIndicator = {0.7, -1.6, 0.4},
        sequenceCount = 4,
        sequenceDuration = 200,
        light = {
            f1 = {0.75, 2.6, -0.2, 0.25, 255, 255, 255, 0}, --front flash
            f2 = {-0.75, 2.6, -0.2, 0.25, 255, 255, 255, 0},
            r1 = {-0.75, -0.27, 0.9, 0.3, 200, 10, 0, 0},
            r2 = {-0.5, -0.27, 0.9, 0.3, 200, 10, 0, 0},
            r3 = {-0.25, -0.27, 0.9, 0.3, 200, 10, 0, 0},
            b1 = {0.75, -0.27, 0.9, 0.35, 0, 50, 255, 0},
            b2 = {0.5, -0.27, 0.9, 0.35, 0, 50, 255, 0},
            b3 = {0.25, -0.27, 0.9, 0.35, 0, 50, 255, 0},
        },
        sequence = {
            [1] = {
				vehicle_light = {"d2", {200, 10, 0}},
				f1 = {strobe = {50, 25}},
				f2 = {strobe = {50, 25}},

				r1 = {strobe = {50, 100, 255, 50}},
				r2 = {strobe = {100, 150, 255, 50}},
				r3 = {strobe = {150, 50, 255, 50}},
				b1 = {strobe = {100, 150, 255, 50}},
				b2 = {strobe = {150, 100, 255, 50}},
				b3 = {strobe = {100, 50, 255, 50}},
            },
			[2] = {
				f1 = {strobe = false},
				f2 = {strobe = false},
				vehicle_light = {"d1", {0, 50, 255}},
			},
            [3] = {
				vehicle_light = {"d2", {200, 10, 0}},
            },
			[4] = {
				vehicle_light = {"d1", {0, 50, 255}},
			},
        }
    },
    [574] = { --Sweeper
        sequenceCount = 2,
        sequenceDuration = 300,
        light = {
            r1 = {-0.35, 0.45, 1.35, 0, 200, 10, 0},
            r2 = {0.35, 0.45, 1.35, 0.3, 200, 10, 0},
        },
        sequence = {
            [1] = {
                r1 = {fade = {0.3}},
                r2 = {fade = {0}},
            },
            [2] = {
                r1 = {fade = {0}},
                r2 = {fade = {0.3}},
            }
        },
    },
    --[[[408] = { --Trashmaster
        lightBar = {0, 0.7, 0.95},
        sequenceCount = 2,
        lightBar = {0, 0.7, 1.35, 1.1, "orange"},
        sequenceDuration = 400,
        light = {
            r2 = {-0.7, 0.7, 1.4, 0, 255, 145, 0},
            r3 = {-0.4, 0.7, 1.4, 0, 255, 145, 0},
            b2 = {0.7, 0.7, 1.4, 0, 255, 145, 0},
            b3 = {0.4, 0.7, 1.4, 0, 255, 145, 0},
        },
        sequence = {
            [1] = {
                r2 = {fade = {0.3}},
                r3 = {fade = {0}},
                b2 = {fade = {0}},
                b3 = {fade = {0.3}},
            },
            [2] = {
                r2 = {fade = {0}},
                r3 = {fade = {0.3}},
                b2 = {fade = {0.3}},
                b3 = {fade = {0}},
            }
        },
    },]]
    ["Sprunk_Truck"] = { --Linerunner
        sequenceCount = 2,
        sequenceDuration = 400,
        light = {
			r1 = {1, 4.4, -0.85, 0.5, 255, 200, 0, 255},
			r2 = {0.7, 2.25, 1.45, 0.5, 255, 200, 0, 255},
			r3 = {1.2, 0, 1.8, 0.5, 255, 200, 0, 255},
			r4 = {1.2, -1, 0, 0.5, 255, 200, 0, 255},
			r5 = {1.2, 2.2, -0.3, 0.5, 255, 200, 0, 255},
			l1 = {-1, 4.4, -0.85, 0.5, 255, 200, 0, 255},
			l2 = {-0.7, 2.25, 1.45, 0.5, 255, 200, 0, 255},
			l3 = {-1.2, 0, 1.8, 0.5, 255, 200, 0, 255},
			l4 = {-1.2, -1, 0, 0.5, 255, 200, 0, 255},
			l5 = {-1.2, 2.2, -0.3, 0.5, 255, 200, 0, 255},
        },
        sequence = {
            [1] = {
                
            },
            [2] = {
        
            }
        },
    },
    ["Sprunk_Trailer"] = { --Trailer 1
        sequenceCount = 2,
        sequenceDuration = 400,
        light = {
			r1 = {1.3, 6.5, 2.2, 0.5, 255, 200, 0, 255},
			r2 = {1.3, 3.07, 2.2, 0.5, 255, 200, 0, 255},
			r3 = {1.3, -0.36, 2.2, 0.5, 255, 200, 0, 255},
			r4 = {1.3, -3.8, 2.2, 0.5, 255, 200, 0, 255},
			l1 = {-1.3, 6.5, 2.2, 0.5, 255, 200, 0, 255},
			l2 = {-1.3, 3.07, 2.2, 0.5, 255, 200, 0, 255},
			l3 = {-1.3, -0.36, 2.2, 0.5, 255, 200, 0, 255},
			l4 = {-1.3, -3.8, 2.2, 0.5, 255, 200, 0, 255},
			--unten
			r5 = {1.3, -3.8, -0.2, 0.5, 255, 200, 0, 255},
			r6 = {1.3, 0, -0.2, 0.5, 255, 200, 0, 255},
			r7 = {1.3, 3.8, 0, 0.5, 255, 200, 0, 255},
			r8 = {1.3, 6.5, 0.2, 0.5, 255, 200, 0, 255},
			l5 = {-1.3, -3.8, -0.2, 0.5, 255, 200, 0, 255},
			l6 = {-1.3, 0, -0.2, 0.5, 255, 200, 0, 255},
			l7 = {-1.3, 3.8, 0, 0.5, 255, 200, 0, 255},
			l8 = {-1.3, 6.5, 0.2, 0.5, 255, 200, 0, 255},
        },
        sequence = {
            [1] = {
                
            },
            [2] = {
        
            }
        },
    },

    ["DFT_Transporter"] = { 
		lightBar = {0, 3.8, 1.45, 1.4, "orange"},
        sequenceCount = 1,
        sequenceDuration = 100,
        light = {
			r1 = {0.4, 3.8, 1.5, 0.05, 255, 200, 0},
            r2 = {-0.4, 3.8, 1.5, 0.05, 255, 200, 0},
            r3 = {0.7, 3.8, 1.5, 0.5, 255, 200, 0},
            r4 = {-0.7, 3.8, 1.5, 0.05, 255, 200, 0},
            r5 = {1, 3.8, 1.5, 0.05, 255, 200, 0},
			r6 = {-1, 3.8, 1.5, 0.5, 255, 200, 0},
			rback = {-1, -4.8, -0.8, 0.4, 255, 200, 0},
        },
        sequence = {
            [1] = {
                r1 = {blink = {0.05, 0.5, 350, 100}},
				r2 = {blink = {0.05, 0.5, 350, 50}},
				r3 = {blink = {0.5, 0.05, 350, 100}},
                r4 = {blink = {0.05, 0.5, 350, 50}},
                r5 = {blink = {0.05, 0.5, 350, 100}},
				r6 = {blink = {0.5, 0, 350, 50}},
				rback = {blink = {0.1, 0.4, 250, 50}},
            }
        },
    },
}