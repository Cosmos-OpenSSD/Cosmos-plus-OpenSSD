################################################################################

# This XDC is used only for OOC mode of synthesis, implementation
# This constraints file contains default clock frequencies to be used during
# out-of-context flows such as OOC Synthesis and Hierarchical Designs.
# This constraints file is not used in normal top-down synthesis (default flow
# of Vivado)
################################################################################
create_clock -name PS_FCLK_CLK0 -period 10 [get_pins PS/FCLK_CLK0]
create_clock -name PS_FCLK_CLK2 -period 5 [get_pins PS/FCLK_CLK2]
create_clock -name PS_FCLK_CLK3 -period 4 [get_pins PS/FCLK_CLK3]

################################################################################