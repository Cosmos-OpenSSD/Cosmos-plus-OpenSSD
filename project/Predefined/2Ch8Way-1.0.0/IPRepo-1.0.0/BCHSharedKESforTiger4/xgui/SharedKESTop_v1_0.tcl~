# Definitional proc to organize widgets for parameters.
proc init_gui { IPINST } {
  ipgui::add_param $IPINST -name "Component_Name"
  #Adding Page
  set Page_0 [ipgui::add_page $IPINST -name "Page 0"]
  ipgui::add_param $IPINST -name "Channel" -parent ${Page_0}
  ipgui::add_param $IPINST -name "ELPCoefficients" -parent ${Page_0}
  ipgui::add_param $IPINST -name "GaloisFieldDegree" -parent ${Page_0}
  ipgui::add_param $IPINST -name "MaxErrorCountBits" -parent ${Page_0}
  ipgui::add_param $IPINST -name "Multi" -parent ${Page_0}
  ipgui::add_param $IPINST -name "Syndromes" -parent ${Page_0}


}

proc update_PARAM_VALUE.Channel { PARAM_VALUE.Channel } {
	# Procedure called to update Channel when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.Channel { PARAM_VALUE.Channel } {
	# Procedure called to validate Channel
	return true
}

proc update_PARAM_VALUE.ELPCoefficients { PARAM_VALUE.ELPCoefficients } {
	# Procedure called to update ELPCoefficients when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.ELPCoefficients { PARAM_VALUE.ELPCoefficients } {
	# Procedure called to validate ELPCoefficients
	return true
}

proc update_PARAM_VALUE.GaloisFieldDegree { PARAM_VALUE.GaloisFieldDegree } {
	# Procedure called to update GaloisFieldDegree when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.GaloisFieldDegree { PARAM_VALUE.GaloisFieldDegree } {
	# Procedure called to validate GaloisFieldDegree
	return true
}

proc update_PARAM_VALUE.MaxErrorCountBits { PARAM_VALUE.MaxErrorCountBits } {
	# Procedure called to update MaxErrorCountBits when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.MaxErrorCountBits { PARAM_VALUE.MaxErrorCountBits } {
	# Procedure called to validate MaxErrorCountBits
	return true
}

proc update_PARAM_VALUE.Multi { PARAM_VALUE.Multi } {
	# Procedure called to update Multi when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.Multi { PARAM_VALUE.Multi } {
	# Procedure called to validate Multi
	return true
}

proc update_PARAM_VALUE.Syndromes { PARAM_VALUE.Syndromes } {
	# Procedure called to update Syndromes when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.Syndromes { PARAM_VALUE.Syndromes } {
	# Procedure called to validate Syndromes
	return true
}


proc update_MODELPARAM_VALUE.Channel { MODELPARAM_VALUE.Channel PARAM_VALUE.Channel } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.Channel}] ${MODELPARAM_VALUE.Channel}
}

proc update_MODELPARAM_VALUE.Multi { MODELPARAM_VALUE.Multi PARAM_VALUE.Multi } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.Multi}] ${MODELPARAM_VALUE.Multi}
}

proc update_MODELPARAM_VALUE.GaloisFieldDegree { MODELPARAM_VALUE.GaloisFieldDegree PARAM_VALUE.GaloisFieldDegree } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.GaloisFieldDegree}] ${MODELPARAM_VALUE.GaloisFieldDegree}
}

proc update_MODELPARAM_VALUE.MaxErrorCountBits { MODELPARAM_VALUE.MaxErrorCountBits PARAM_VALUE.MaxErrorCountBits } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.MaxErrorCountBits}] ${MODELPARAM_VALUE.MaxErrorCountBits}
}

proc update_MODELPARAM_VALUE.Syndromes { MODELPARAM_VALUE.Syndromes PARAM_VALUE.Syndromes } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.Syndromes}] ${MODELPARAM_VALUE.Syndromes}
}

proc update_MODELPARAM_VALUE.ELPCoefficients { MODELPARAM_VALUE.ELPCoefficients PARAM_VALUE.ELPCoefficients } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.ELPCoefficients}] ${MODELPARAM_VALUE.ELPCoefficients}
}

