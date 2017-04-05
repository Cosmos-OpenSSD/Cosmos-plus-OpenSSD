# Definitional proc to organize widgets for parameters.
proc init_gui { IPINST } {
  ipgui::add_param $IPINST -name "Component_Name"
  #Adding Page
  set Page_0 [ipgui::add_page $IPINST -name "Page 0"]
  ipgui::add_param $IPINST -name "NumberOfWays" -parent ${Page_0}
  ipgui::add_param $IPINST -name "IDelayValue" -parent ${Page_0}
  ipgui::add_param $IPINST -name "InputClockBufferType" -parent ${Page_0}
  ipgui::add_static_text $IPINST -name "Clock buffer type" -parent ${Page_0} -text {
Clock buffer type hint
0: IBUFG (default)
1: IBUFG + BUFG
2: BUFR}


}

proc update_PARAM_VALUE.IDelayValue { PARAM_VALUE.IDelayValue } {
	# Procedure called to update IDelayValue when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.IDelayValue { PARAM_VALUE.IDelayValue } {
	# Procedure called to validate IDelayValue
	return true
}

proc update_PARAM_VALUE.InputClockBufferType { PARAM_VALUE.InputClockBufferType } {
	# Procedure called to update InputClockBufferType when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.InputClockBufferType { PARAM_VALUE.InputClockBufferType } {
	# Procedure called to validate InputClockBufferType
	return true
}

proc update_PARAM_VALUE.NumberOfWays { PARAM_VALUE.NumberOfWays } {
	# Procedure called to update NumberOfWays when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.NumberOfWays { PARAM_VALUE.NumberOfWays } {
	# Procedure called to validate NumberOfWays
	return true
}


proc update_MODELPARAM_VALUE.NumberOfWays { MODELPARAM_VALUE.NumberOfWays PARAM_VALUE.NumberOfWays } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.NumberOfWays}] ${MODELPARAM_VALUE.NumberOfWays}
}

proc update_MODELPARAM_VALUE.IDelayValue { MODELPARAM_VALUE.IDelayValue PARAM_VALUE.IDelayValue } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.IDelayValue}] ${MODELPARAM_VALUE.IDelayValue}
}

proc update_MODELPARAM_VALUE.InputClockBufferType { MODELPARAM_VALUE.InputClockBufferType PARAM_VALUE.InputClockBufferType } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.InputClockBufferType}] ${MODELPARAM_VALUE.InputClockBufferType}
}

