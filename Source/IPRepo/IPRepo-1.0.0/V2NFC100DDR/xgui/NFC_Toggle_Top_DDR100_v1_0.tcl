# Definitional proc to organize widgets for parameters.
proc init_gui { IPINST } {
  ipgui::add_param $IPINST -name "Component_Name"
  #Adding Page
  set Page_0 [ipgui::add_page $IPINST -name "Page 0"]
  ipgui::add_param $IPINST -name "NumberOfWays" -parent ${Page_0}
  ipgui::add_param $IPINST -name "NumofbCMD" -parent ${Page_0}


}

proc update_PARAM_VALUE.NumberOfWays { PARAM_VALUE.NumberOfWays } {
	# Procedure called to update NumberOfWays when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.NumberOfWays { PARAM_VALUE.NumberOfWays } {
	# Procedure called to validate NumberOfWays
	return true
}

proc update_PARAM_VALUE.NumofbCMD { PARAM_VALUE.NumofbCMD } {
	# Procedure called to update NumofbCMD when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.NumofbCMD { PARAM_VALUE.NumofbCMD } {
	# Procedure called to validate NumofbCMD
	return true
}


proc update_MODELPARAM_VALUE.NumofbCMD { MODELPARAM_VALUE.NumofbCMD PARAM_VALUE.NumofbCMD } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.NumofbCMD}] ${MODELPARAM_VALUE.NumofbCMD}
}

proc update_MODELPARAM_VALUE.NumberOfWays { MODELPARAM_VALUE.NumberOfWays PARAM_VALUE.NumberOfWays } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.NumberOfWays}] ${MODELPARAM_VALUE.NumberOfWays}
}

