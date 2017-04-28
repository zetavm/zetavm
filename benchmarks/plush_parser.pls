#zeta-image

exports_obj = { init: @fun_1 };
global_obj = { exports: @exports_obj };

block_5 = {
  instrs: [
    { op:'get_local', idx:0 },
    { op:'get_local', idx:1 },
    { op:'add_i64' },
    { op:'ret' },
  ]
};

block_4 = {
  instrs: [
    { op:'get_local', idx:1 },
    { op:'has_tag', tag:'int64' },
    { op:'if_true', then:@block_5, else:@block_6 },
  ]
};

block_6 = {
  instrs: [
    { op:'jump', to:@block_7 },
  ]
};

block_2 = {
  instrs: [
    { op:'get_local', idx:0 },
    { op:'has_tag', tag:'int64' },
    { op:'if_true', then:@block_4, else:@block_8 },
  ]
};

block_7 = {
  instrs: [
    { op:'jump', to:@block_9 },
  ]
};

block_8 = {
  instrs: [
    { op:'jump', to:@block_9 },
  ]
};

block_11 = {
  instrs: [
    { op:'get_local', idx:0 },
    { op:'get_local', idx:1 },
    { op:'str_cat' },
    { op:'ret' },
  ]
};

block_10 = {
  instrs: [
    { op:'get_local', idx:1 },
    { op:'has_tag', tag:'string' },
    { op:'if_true', then:@block_11, else:@block_12 },
  ]
};

block_12 = {
  instrs: [
    { op:'jump', to:@block_13 },
  ]
};

block_9 = {
  instrs: [
    { op:'get_local', idx:0 },
    { op:'has_tag', tag:'string' },
    { op:'if_true', then:@block_10, else:@block_14 },
  ]
};

block_13 = {
  instrs: [
    { op:'jump', to:@block_15 },
  ]
};

block_14 = {
  instrs: [
    { op:'jump', to:@block_15 },
  ]
};

block_15 = {
  instrs: [
    { op:'push', val:$false },
    { op:'if_true', then:@block_16, else:@block_17 },
  ]
};

block_16 = {
  instrs: [
    { op:'jump', to:@block_18 },
  ]
};

block_17 = {
  instrs: [
    { op:'push', val:'unhandled type in addition' },
    { op:'abort' },
    { op:'jump', to:@block_18 },
  ]
};

block_18 = {
  instrs: [
    { op:'push', val:$undef },
    { op:'ret' },
  ]
};

fun_3 = {
  entry:@block_2,
  num_params:2,
  num_locals:2,
};

block_22 = {
  instrs: [
    { op:'get_local', idx:0 },
    { op:'get_local', idx:1 },
    { op:'sub_i64' },
    { op:'ret' },
  ]
};

block_21 = {
  instrs: [
    { op:'get_local', idx:1 },
    { op:'has_tag', tag:'int64' },
    { op:'if_true', then:@block_22, else:@block_23 },
  ]
};

block_23 = {
  instrs: [
    { op:'jump', to:@block_24 },
  ]
};

block_19 = {
  instrs: [
    { op:'get_local', idx:0 },
    { op:'has_tag', tag:'int64' },
    { op:'if_true', then:@block_21, else:@block_25 },
  ]
};

block_24 = {
  instrs: [
    { op:'jump', to:@block_26 },
  ]
};

block_25 = {
  instrs: [
    { op:'jump', to:@block_26 },
  ]
};

block_26 = {
  instrs: [
    { op:'push', val:$false },
    { op:'if_true', then:@block_27, else:@block_28 },
  ]
};

block_27 = {
  instrs: [
    { op:'jump', to:@block_29 },
  ]
};

block_28 = {
  instrs: [
    { op:'push', val:'unhandled type in subtraction' },
    { op:'abort' },
    { op:'jump', to:@block_29 },
  ]
};

block_29 = {
  instrs: [
    { op:'push', val:$undef },
    { op:'ret' },
  ]
};

fun_20 = {
  entry:@block_19,
  num_params:2,
  num_locals:2,
};

block_32 = {
  instrs: [
    { op:'push', val:$false },
    { op:'ret' },
  ]
};

block_33 = {
  instrs: [
    { op:'push', val:$true },
    { op:'ret' },
  ]
};

block_30 = {
  instrs: [
    { op:'get_local', idx:0 },
    { op:'if_true', then:@block_32, else:@block_33 },
  ]
};

block_34 = {
  instrs: [
    { op:'push', val:$undef },
    { op:'ret' },
  ]
};

fun_31 = {
  entry:@block_30,
  num_params:1,
  num_locals:1,
};

block_38 = {
  instrs: [
    { op:'get_local', idx:0 },
    { op:'get_local', idx:1 },
    { op:'eq_i64' },
    { op:'ret' },
  ]
};

block_37 = {
  instrs: [
    { op:'get_local', idx:1 },
    { op:'has_tag', tag:'int64' },
    { op:'if_true', then:@block_38, else:@block_39 },
  ]
};

block_39 = {
  instrs: [
    { op:'jump', to:@block_40 },
  ]
};

block_35 = {
  instrs: [
    { op:'get_local', idx:0 },
    { op:'has_tag', tag:'int64' },
    { op:'if_true', then:@block_37, else:@block_41 },
  ]
};

block_40 = {
  instrs: [
    { op:'jump', to:@block_42 },
  ]
};

block_41 = {
  instrs: [
    { op:'jump', to:@block_42 },
  ]
};

block_44 = {
  instrs: [
    { op:'get_local', idx:0 },
    { op:'get_local', idx:1 },
    { op:'eq_str' },
    { op:'ret' },
  ]
};

block_43 = {
  instrs: [
    { op:'get_local', idx:1 },
    { op:'has_tag', tag:'string' },
    { op:'if_true', then:@block_44, else:@block_45 },
  ]
};

block_45 = {
  instrs: [
    { op:'jump', to:@block_46 },
  ]
};

block_46 = {
  instrs: [
    { op:'push', val:$false },
    { op:'ret' },
  ]
};

block_42 = {
  instrs: [
    { op:'get_local', idx:0 },
    { op:'has_tag', tag:'string' },
    { op:'if_true', then:@block_43, else:@block_47 },
  ]
};

block_47 = {
  instrs: [
    { op:'jump', to:@block_48 },
  ]
};

block_50 = {
  instrs: [
    { op:'get_local', idx:0 },
    { op:'get_local', idx:1 },
    { op:'eq_obj' },
    { op:'ret' },
  ]
};

block_49 = {
  instrs: [
    { op:'get_local', idx:1 },
    { op:'has_tag', tag:'object' },
    { op:'if_true', then:@block_50, else:@block_51 },
  ]
};

block_51 = {
  instrs: [
    { op:'jump', to:@block_52 },
  ]
};

block_52 = {
  instrs: [
    { op:'push', val:$false },
    { op:'ret' },
  ]
};

block_48 = {
  instrs: [
    { op:'get_local', idx:0 },
    { op:'has_tag', tag:'object' },
    { op:'if_true', then:@block_49, else:@block_53 },
  ]
};

block_53 = {
  instrs: [
    { op:'jump', to:@block_54 },
  ]
};

block_56 = {
  instrs: [
    { op:'get_local', idx:0 },
    { op:'get_local', idx:1 },
    { op:'eq_bool' },
    { op:'ret' },
  ]
};

block_55 = {
  instrs: [
    { op:'get_local', idx:1 },
    { op:'has_tag', tag:'bool' },
    { op:'if_true', then:@block_56, else:@block_57 },
  ]
};

block_57 = {
  instrs: [
    { op:'jump', to:@block_58 },
  ]
};

block_58 = {
  instrs: [
    { op:'push', val:$false },
    { op:'ret' },
  ]
};

block_54 = {
  instrs: [
    { op:'get_local', idx:0 },
    { op:'has_tag', tag:'bool' },
    { op:'if_true', then:@block_55, else:@block_59 },
  ]
};

block_59 = {
  instrs: [
    { op:'jump', to:@block_60 },
  ]
};

block_62 = {
  instrs: [
    { op:'push', val:$true },
    { op:'ret' },
  ]
};

block_61 = {
  instrs: [
    { op:'get_local', idx:1 },
    { op:'has_tag', tag:'undef' },
    { op:'if_true', then:@block_62, else:@block_63 },
  ]
};

block_63 = {
  instrs: [
    { op:'jump', to:@block_64 },
  ]
};

block_64 = {
  instrs: [
    { op:'push', val:$false },
    { op:'ret' },
  ]
};

block_60 = {
  instrs: [
    { op:'get_local', idx:0 },
    { op:'has_tag', tag:'undef' },
    { op:'if_true', then:@block_61, else:@block_65 },
  ]
};

block_65 = {
  instrs: [
    { op:'jump', to:@block_66 },
  ]
};

block_66 = {
  instrs: [
    { op:'push', val:$false },
    { op:'if_true', then:@block_67, else:@block_68 },
  ]
};

block_67 = {
  instrs: [
    { op:'jump', to:@block_69 },
  ]
};

block_68 = {
  instrs: [
    { op:'push', val:'unhandled type in equality comparison' },
    { op:'abort' },
    { op:'jump', to:@block_69 },
  ]
};

block_69 = {
  instrs: [
    { op:'push', val:$undef },
    { op:'ret' },
  ]
};

fun_36 = {
  entry:@block_35,
  num_params:2,
  num_locals:2,
};

block_70 = {
  instrs: [
    { op:'get_local', idx:0 },
    { op:'get_local', idx:1 },
    { op:'push', val:@global_obj },
    { op:'push', val:'rt_eq' },
    { op:'get_field' },
    { op:'call', ret_to:@block_72, num_args:2 },
  ]
};

block_73 = {
  instrs: [
    { op:'push', val:$false },
    { op:'ret' },
  ]
};

block_74 = {
  instrs: [
    { op:'push', val:$true },
    { op:'ret' },
  ]
};

block_72 = {
  instrs: [
    { op:'if_true', then:@block_73, else:@block_74 },
  ]
};

block_75 = {
  instrs: [
    { op:'push', val:$undef },
    { op:'ret' },
  ]
};

fun_71 = {
  entry:@block_70,
  num_params:2,
  num_locals:2,
};

block_79 = {
  instrs: [
    { op:'get_local', idx:0 },
    { op:'get_local', idx:1 },
    { op:'le_i64' },
    { op:'ret' },
  ]
};

block_78 = {
  instrs: [
    { op:'get_local', idx:1 },
    { op:'has_tag', tag:'int64' },
    { op:'if_true', then:@block_79, else:@block_80 },
  ]
};

block_80 = {
  instrs: [
    { op:'jump', to:@block_81 },
  ]
};

block_76 = {
  instrs: [
    { op:'get_local', idx:0 },
    { op:'has_tag', tag:'int64' },
    { op:'if_true', then:@block_78, else:@block_82 },
  ]
};

block_81 = {
  instrs: [
    { op:'jump', to:@block_83 },
  ]
};

block_82 = {
  instrs: [
    { op:'jump', to:@block_83 },
  ]
};

block_85 = {
  instrs: [
    { op:'get_local', idx:0 },
    { op:'str_len' },
    { op:'push', val:1 },
    { op:'eq_i64' },
    { op:'if_true', then:@block_86, else:@block_87 },
  ]
};

block_86 = {
  instrs: [
    { op:'jump', to:@block_88 },
  ]
};

block_87 = {
  instrs: [
    { op:'push', val:'rt_le' },
    { op:'abort' },
    { op:'jump', to:@block_88 },
  ]
};

block_88 = {
  instrs: [
    { op:'get_local', idx:1 },
    { op:'str_len' },
    { op:'push', val:1 },
    { op:'eq_i64' },
    { op:'if_true', then:@block_89, else:@block_90 },
  ]
};

block_89 = {
  instrs: [
    { op:'jump', to:@block_91 },
  ]
};

block_90 = {
  instrs: [
    { op:'push', val:'rt_le' },
    { op:'abort' },
    { op:'jump', to:@block_91 },
  ]
};

block_91 = {
  instrs: [
    { op:'get_local', idx:0 },
    { op:'push', val:0 },
    { op:'get_char_code' },
    { op:'get_local', idx:1 },
    { op:'push', val:0 },
    { op:'get_char_code' },
    { op:'push', val:@global_obj },
    { op:'push', val:'rt_le' },
    { op:'get_field' },
    { op:'call', ret_to:@block_92, num_args:2 },
  ]
};

block_92 = {
  instrs: [
    { op:'ret' },
  ]
};

block_84 = {
  instrs: [
    { op:'get_local', idx:1 },
    { op:'has_tag', tag:'string' },
    { op:'if_true', then:@block_85, else:@block_93 },
  ]
};

block_93 = {
  instrs: [
    { op:'jump', to:@block_94 },
  ]
};

block_83 = {
  instrs: [
    { op:'get_local', idx:0 },
    { op:'has_tag', tag:'string' },
    { op:'if_true', then:@block_84, else:@block_95 },
  ]
};

block_94 = {
  instrs: [
    { op:'jump', to:@block_96 },
  ]
};

block_95 = {
  instrs: [
    { op:'jump', to:@block_96 },
  ]
};

block_96 = {
  instrs: [
    { op:'push', val:$false },
    { op:'if_true', then:@block_97, else:@block_98 },
  ]
};

block_97 = {
  instrs: [
    { op:'jump', to:@block_99 },
  ]
};

block_98 = {
  instrs: [
    { op:'push', val:'unhandled type in less-than or equal comparison' },
    { op:'abort' },
    { op:'jump', to:@block_99 },
  ]
};

block_99 = {
  instrs: [
    { op:'push', val:$undef },
    { op:'ret' },
  ]
};

fun_77 = {
  entry:@block_76,
  num_params:2,
  num_locals:2,
};

block_103 = {
  instrs: [
    { op:'get_local', idx:0 },
    { op:'get_local', idx:1 },
    { op:'ge_i64' },
    { op:'ret' },
  ]
};

block_102 = {
  instrs: [
    { op:'get_local', idx:1 },
    { op:'has_tag', tag:'int64' },
    { op:'if_true', then:@block_103, else:@block_104 },
  ]
};

block_104 = {
  instrs: [
    { op:'jump', to:@block_105 },
  ]
};

block_100 = {
  instrs: [
    { op:'get_local', idx:0 },
    { op:'has_tag', tag:'int64' },
    { op:'if_true', then:@block_102, else:@block_106 },
  ]
};

block_105 = {
  instrs: [
    { op:'jump', to:@block_107 },
  ]
};

block_106 = {
  instrs: [
    { op:'jump', to:@block_107 },
  ]
};

block_109 = {
  instrs: [
    { op:'get_local', idx:0 },
    { op:'str_len' },
    { op:'push', val:1 },
    { op:'eq_i64' },
    { op:'if_true', then:@block_110, else:@block_111 },
  ]
};

block_110 = {
  instrs: [
    { op:'jump', to:@block_112 },
  ]
};

block_111 = {
  instrs: [
    { op:'push', val:'rt_ge' },
    { op:'abort' },
    { op:'jump', to:@block_112 },
  ]
};

block_112 = {
  instrs: [
    { op:'get_local', idx:1 },
    { op:'str_len' },
    { op:'push', val:1 },
    { op:'eq_i64' },
    { op:'if_true', then:@block_113, else:@block_114 },
  ]
};

block_113 = {
  instrs: [
    { op:'jump', to:@block_115 },
  ]
};

block_114 = {
  instrs: [
    { op:'push', val:'rt_ge' },
    { op:'abort' },
    { op:'jump', to:@block_115 },
  ]
};

block_115 = {
  instrs: [
    { op:'get_local', idx:0 },
    { op:'push', val:0 },
    { op:'get_char_code' },
    { op:'get_local', idx:1 },
    { op:'push', val:0 },
    { op:'get_char_code' },
    { op:'push', val:@global_obj },
    { op:'push', val:'rt_ge' },
    { op:'get_field' },
    { op:'call', ret_to:@block_116, num_args:2 },
  ]
};

block_116 = {
  instrs: [
    { op:'ret' },
  ]
};

block_108 = {
  instrs: [
    { op:'get_local', idx:1 },
    { op:'has_tag', tag:'string' },
    { op:'if_true', then:@block_109, else:@block_117 },
  ]
};

block_117 = {
  instrs: [
    { op:'jump', to:@block_118 },
  ]
};

block_107 = {
  instrs: [
    { op:'get_local', idx:0 },
    { op:'has_tag', tag:'string' },
    { op:'if_true', then:@block_108, else:@block_119 },
  ]
};

block_118 = {
  instrs: [
    { op:'jump', to:@block_120 },
  ]
};

block_119 = {
  instrs: [
    { op:'jump', to:@block_120 },
  ]
};

block_120 = {
  instrs: [
    { op:'push', val:$false },
    { op:'if_true', then:@block_121, else:@block_122 },
  ]
};

block_121 = {
  instrs: [
    { op:'jump', to:@block_123 },
  ]
};

block_122 = {
  instrs: [
    { op:'push', val:'unhandled type in less-than or equal comparison' },
    { op:'abort' },
    { op:'jump', to:@block_123 },
  ]
};

block_123 = {
  instrs: [
    { op:'push', val:$undef },
    { op:'ret' },
  ]
};

fun_101 = {
  entry:@block_100,
  num_params:2,
  num_locals:2,
};

block_127 = {
  instrs: [
    { op:'get_local', idx:1 },
    { op:'get_local', idx:0 },
    { op:'has_field' },
    { op:'ret' },
  ]
};

block_126 = {
  instrs: [
    { op:'get_local', idx:1 },
    { op:'has_tag', tag:'object' },
    { op:'if_true', then:@block_127, else:@block_128 },
  ]
};

block_128 = {
  instrs: [
    { op:'jump', to:@block_129 },
  ]
};

block_124 = {
  instrs: [
    { op:'get_local', idx:0 },
    { op:'has_tag', tag:'string' },
    { op:'if_true', then:@block_126, else:@block_130 },
  ]
};

block_129 = {
  instrs: [
    { op:'jump', to:@block_131 },
  ]
};

block_130 = {
  instrs: [
    { op:'jump', to:@block_131 },
  ]
};

block_131 = {
  instrs: [
    { op:'push', val:$false },
    { op:'if_true', then:@block_132, else:@block_133 },
  ]
};

block_132 = {
  instrs: [
    { op:'jump', to:@block_134 },
  ]
};

block_133 = {
  instrs: [
    { op:'push', val:'unhandled type in the \'in\' operator' },
    { op:'abort' },
    { op:'jump', to:@block_134 },
  ]
};

block_134 = {
  instrs: [
    { op:'push', val:$undef },
    { op:'ret' },
  ]
};

fun_125 = {
  entry:@block_124,
  num_params:2,
  num_locals:2,
};

block_135 = {
  instrs: [
    { op:'get_local', idx:0 },
    { op:'has_tag', tag:'object' },
    { op:'if_true', then:@block_137, else:@block_138 },
  ]
};

block_137 = {
  instrs: [
    { op:'jump', to:@block_139 },
  ]
};

block_138 = {
  instrs: [
    { op:'push', val:'instanceof only applies to objects' },
    { op:'abort' },
    { op:'jump', to:@block_139 },
  ]
};

block_139 = {
  instrs: [
    { op:'get_local', idx:1 },
    { op:'has_tag', tag:'object' },
    { op:'if_true', then:@block_140, else:@block_141 },
  ]
};

block_140 = {
  instrs: [
    { op:'jump', to:@block_142 },
  ]
};

block_141 = {
  instrs: [
    { op:'push', val:'prototype in instanceof must be an object' },
    { op:'abort' },
    { op:'jump', to:@block_142 },
  ]
};

block_144 = {
  instrs: [
    { op:'push', val:$true },
    { op:'ret' },
  ]
};

block_143 = {
  instrs: [
    { op:'get_local', idx:0 },
    { op:'push', val:'proto' },
    { op:'get_field' },
    { op:'set_local', idx:2 },
    { op:'get_local', idx:2 },
    { op:'get_local', idx:1 },
    { op:'eq_obj' },
    { op:'if_true', then:@block_144, else:@block_145 },
  ]
};

block_145 = {
  instrs: [
    { op:'jump', to:@block_146 },
  ]
};

block_146 = {
  instrs: [
    { op:'get_local', idx:2 },
    { op:'get_local', idx:1 },
    { op:'push', val:@global_obj },
    { op:'push', val:'rt_instOf' },
    { op:'get_field' },
    { op:'call', ret_to:@block_147, num_args:2 },
  ]
};

block_147 = {
  instrs: [
    { op:'ret' },
  ]
};

block_142 = {
  instrs: [
    { op:'get_local', idx:0 },
    { op:'push', val:'proto' },
    { op:'has_field' },
    { op:'if_true', then:@block_143, else:@block_148 },
  ]
};

block_148 = {
  instrs: [
    { op:'jump', to:@block_149 },
  ]
};

block_149 = {
  instrs: [
    { op:'push', val:$false },
    { op:'ret' },
  ]
};

fun_136 = {
  entry:@block_135,
  num_params:2,
  num_locals:3,
};

block_153 = {
  instrs: [
    { op:'get_local', idx:0 },
    { op:'get_local', idx:1 },
    { op:'get_field' },
    { op:'ret' },
  ]
};

block_152 = {
  instrs: [
    { op:'get_local', idx:0 },
    { op:'get_local', idx:1 },
    { op:'has_field' },
    { op:'if_true', then:@block_153, else:@block_154 },
  ]
};

block_154 = {
  instrs: [
    { op:'jump', to:@block_155 },
  ]
};

block_156 = {
  instrs: [
    { op:'get_local', idx:0 },
    { op:'push', val:'proto' },
    { op:'get_field' },
    { op:'set_local', idx:2 },
    { op:'get_local', idx:2 },
    { op:'get_local', idx:1 },
    { op:'push', val:@global_obj },
    { op:'push', val:'rt_getProp' },
    { op:'get_field' },
    { op:'call', ret_to:@block_157, num_args:2 },
  ]
};

block_157 = {
  instrs: [
    { op:'ret' },
  ]
};

block_155 = {
  instrs: [
    { op:'get_local', idx:0 },
    { op:'push', val:'proto' },
    { op:'has_field' },
    { op:'if_true', then:@block_156, else:@block_158 },
  ]
};

block_158 = {
  instrs: [
    { op:'jump', to:@block_159 },
  ]
};

block_161 = {
  instrs: [
    { op:'push', val:'undefined property \"' },
    { op:'get_local', idx:1 },
    { op:'push', val:@global_obj },
    { op:'push', val:'rt_add' },
    { op:'get_field' },
    { op:'call', ret_to:@block_162, num_args:2 },
  ]
};

block_162 = {
  instrs: [
    { op:'push', val:'\"' },
    { op:'push', val:@global_obj },
    { op:'push', val:'rt_add' },
    { op:'get_field' },
    { op:'call', ret_to:@block_163, num_args:2 },
  ]
};

block_159 = {
  instrs: [
    { op:'push', val:$false },
    { op:'if_true', then:@block_160, else:@block_161 },
  ]
};

block_160 = {
  instrs: [
    { op:'jump', to:@block_164 },
  ]
};

block_163 = {
  instrs: [
    { op:'abort' },
    { op:'jump', to:@block_164 },
  ]
};

block_150 = {
  instrs: [
    { op:'get_local', idx:0 },
    { op:'has_tag', tag:'object' },
    { op:'if_true', then:@block_152, else:@block_165 },
  ]
};

block_164 = {
  instrs: [
    { op:'jump', to:@block_166 },
  ]
};

block_165 = {
  instrs: [
    { op:'jump', to:@block_166 },
  ]
};

block_167 = {
  instrs: [
    { op:'get_local', idx:1 },
    { op:'push', val:'length' },
    { op:'push', val:@global_obj },
    { op:'push', val:'rt_eq' },
    { op:'get_field' },
    { op:'call', ret_to:@block_168, num_args:2 },
  ]
};

block_169 = {
  instrs: [
    { op:'get_local', idx:0 },
    { op:'array_len' },
    { op:'ret' },
  ]
};

block_168 = {
  instrs: [
    { op:'if_true', then:@block_169, else:@block_170 },
  ]
};

block_170 = {
  instrs: [
    { op:'jump', to:@block_171 },
  ]
};

block_171 = {
  instrs: [
    { op:'get_local', idx:1 },
    { op:'push', val:'push' },
    { op:'push', val:@global_obj },
    { op:'push', val:'rt_eq' },
    { op:'get_field' },
    { op:'call', ret_to:@block_172, num_args:2 },
  ]
};

block_173 = {
  instrs: [
    { op:'push', val:@global_obj },
    { op:'push', val:'rt_push' },
    { op:'get_field' },
    { op:'ret' },
  ]
};

block_172 = {
  instrs: [
    { op:'if_true', then:@block_173, else:@block_174 },
  ]
};

block_174 = {
  instrs: [
    { op:'jump', to:@block_175 },
  ]
};

block_166 = {
  instrs: [
    { op:'get_local', idx:0 },
    { op:'has_tag', tag:'array' },
    { op:'if_true', then:@block_167, else:@block_176 },
  ]
};

block_175 = {
  instrs: [
    { op:'jump', to:@block_177 },
  ]
};

block_176 = {
  instrs: [
    { op:'jump', to:@block_177 },
  ]
};

block_178 = {
  instrs: [
    { op:'get_local', idx:1 },
    { op:'push', val:'length' },
    { op:'push', val:@global_obj },
    { op:'push', val:'rt_eq' },
    { op:'get_field' },
    { op:'call', ret_to:@block_179, num_args:2 },
  ]
};

block_180 = {
  instrs: [
    { op:'get_local', idx:0 },
    { op:'str_len' },
    { op:'ret' },
  ]
};

block_179 = {
  instrs: [
    { op:'if_true', then:@block_180, else:@block_181 },
  ]
};

block_181 = {
  instrs: [
    { op:'jump', to:@block_182 },
  ]
};

block_177 = {
  instrs: [
    { op:'get_local', idx:0 },
    { op:'has_tag', tag:'string' },
    { op:'if_true', then:@block_178, else:@block_183 },
  ]
};

block_182 = {
  instrs: [
    { op:'jump', to:@block_184 },
  ]
};

block_183 = {
  instrs: [
    { op:'jump', to:@block_184 },
  ]
};

block_186 = {
  instrs: [
    { op:'push', val:'unhandled base type in read of property \"' },
    { op:'get_local', idx:1 },
    { op:'push', val:@global_obj },
    { op:'push', val:'rt_add' },
    { op:'get_field' },
    { op:'call', ret_to:@block_187, num_args:2 },
  ]
};

block_187 = {
  instrs: [
    { op:'push', val:'\"' },
    { op:'push', val:@global_obj },
    { op:'push', val:'rt_add' },
    { op:'get_field' },
    { op:'call', ret_to:@block_188, num_args:2 },
  ]
};

block_184 = {
  instrs: [
    { op:'push', val:$false },
    { op:'if_true', then:@block_185, else:@block_186 },
  ]
};

block_185 = {
  instrs: [
    { op:'jump', to:@block_189 },
  ]
};

block_188 = {
  instrs: [
    { op:'abort' },
    { op:'jump', to:@block_189 },
  ]
};

block_189 = {
  instrs: [
    { op:'push', val:$undef },
    { op:'ret' },
  ]
};

fun_151 = {
  entry:@block_150,
  num_params:2,
  num_locals:3,
};

block_192 = {
  instrs: [
    { op:'get_local', idx:0 },
    { op:'get_local', idx:1 },
    { op:'get_elem' },
    { op:'ret' },
  ]
};

block_190 = {
  instrs: [
    { op:'get_local', idx:0 },
    { op:'has_tag', tag:'array' },
    { op:'if_true', then:@block_192, else:@block_193 },
  ]
};

block_193 = {
  instrs: [
    { op:'jump', to:@block_194 },
  ]
};

block_195 = {
  instrs: [
    { op:'get_local', idx:0 },
    { op:'get_local', idx:1 },
    { op:'get_char' },
    { op:'ret' },
  ]
};

block_194 = {
  instrs: [
    { op:'get_local', idx:0 },
    { op:'has_tag', tag:'string' },
    { op:'if_true', then:@block_195, else:@block_196 },
  ]
};

block_196 = {
  instrs: [
    { op:'jump', to:@block_197 },
  ]
};

block_197 = {
  instrs: [
    { op:'push', val:$false },
    { op:'if_true', then:@block_198, else:@block_199 },
  ]
};

block_198 = {
  instrs: [
    { op:'jump', to:@block_200 },
  ]
};

block_199 = {
  instrs: [
    { op:'push', val:'assertion failed' },
    { op:'abort' },
    { op:'jump', to:@block_200 },
  ]
};

block_200 = {
  instrs: [
    { op:'push', val:$undef },
    { op:'ret' },
  ]
};

fun_191 = {
  entry:@block_190,
  num_params:2,
  num_locals:2,
};

block_201 = {
  instrs: [
    { op:'get_local', idx:0 },
    { op:'get_local', idx:1 },
    { op:'array_push' },
    { op:'push', val:$undef },
    { op:'ret' },
  ]
};

fun_202 = {
  entry:@block_201,
  num_params:2,
  num_locals:2,
};

block_205 = {
  instrs: [
    { op:'get_local', idx:0 },
    { op:'push', val:@global_obj },
    { op:'push', val:'io' },
    { op:'get_field' },
    { op:'push', val:'print_str' },
    { op:'push', val:@global_obj },
    { op:'push', val:'rt_getProp' },
    { op:'get_field' },
    { op:'call', ret_to:@block_206, num_args:2 },
  ]
};

block_206 = {
  instrs: [
    { op:'call', ret_to:@block_207, num_args:1 },
  ]
};

block_207 = {
  instrs: [
    { op:'pop' },
    { op:'push', val:$undef },
    { op:'ret' },
  ]
};

block_203 = {
  instrs: [
    { op:'get_local', idx:0 },
    { op:'has_tag', tag:'string' },
    { op:'if_true', then:@block_205, else:@block_208 },
  ]
};

block_208 = {
  instrs: [
    { op:'jump', to:@block_209 },
  ]
};

block_210 = {
  instrs: [
    { op:'get_local', idx:0 },
    { op:'push', val:@global_obj },
    { op:'push', val:'io' },
    { op:'get_field' },
    { op:'push', val:'print_int64' },
    { op:'push', val:@global_obj },
    { op:'push', val:'rt_getProp' },
    { op:'get_field' },
    { op:'call', ret_to:@block_211, num_args:2 },
  ]
};

block_211 = {
  instrs: [
    { op:'call', ret_to:@block_212, num_args:1 },
  ]
};

block_212 = {
  instrs: [
    { op:'pop' },
    { op:'push', val:$undef },
    { op:'ret' },
  ]
};

block_209 = {
  instrs: [
    { op:'get_local', idx:0 },
    { op:'has_tag', tag:'int64' },
    { op:'if_true', then:@block_210, else:@block_213 },
  ]
};

block_213 = {
  instrs: [
    { op:'jump', to:@block_214 },
  ]
};

block_214 = {
  instrs: [
    { op:'get_local', idx:0 },
    { op:'push', val:$true },
    { op:'push', val:@global_obj },
    { op:'push', val:'rt_eq' },
    { op:'get_field' },
    { op:'call', ret_to:@block_215, num_args:2 },
  ]
};

block_216 = {
  instrs: [
    { op:'push', val:'true' },
    { op:'push', val:@global_obj },
    { op:'push', val:'output' },
    { op:'get_field' },
    { op:'call', ret_to:@block_217, num_args:1 },
  ]
};

block_217 = {
  instrs: [
    { op:'pop' },
    { op:'push', val:$undef },
    { op:'ret' },
  ]
};

block_215 = {
  instrs: [
    { op:'if_true', then:@block_216, else:@block_218 },
  ]
};

block_218 = {
  instrs: [
    { op:'jump', to:@block_219 },
  ]
};

block_219 = {
  instrs: [
    { op:'get_local', idx:0 },
    { op:'push', val:$false },
    { op:'push', val:@global_obj },
    { op:'push', val:'rt_eq' },
    { op:'get_field' },
    { op:'call', ret_to:@block_220, num_args:2 },
  ]
};

block_221 = {
  instrs: [
    { op:'push', val:'false' },
    { op:'push', val:@global_obj },
    { op:'push', val:'output' },
    { op:'get_field' },
    { op:'call', ret_to:@block_222, num_args:1 },
  ]
};

block_222 = {
  instrs: [
    { op:'pop' },
    { op:'push', val:$undef },
    { op:'ret' },
  ]
};

block_220 = {
  instrs: [
    { op:'if_true', then:@block_221, else:@block_223 },
  ]
};

block_223 = {
  instrs: [
    { op:'jump', to:@block_224 },
  ]
};

block_224 = {
  instrs: [
    { op:'push', val:$false },
    { op:'if_true', then:@block_225, else:@block_226 },
  ]
};

block_225 = {
  instrs: [
    { op:'jump', to:@block_227 },
  ]
};

block_226 = {
  instrs: [
    { op:'push', val:'unhandled type in output function' },
    { op:'abort' },
    { op:'jump', to:@block_227 },
  ]
};

block_227 = {
  instrs: [
    { op:'push', val:$undef },
    { op:'ret' },
  ]
};

fun_204 = {
  entry:@block_203,
  num_params:1,
  num_locals:1,
};

block_228 = {
  instrs: [
    { op:'get_local', idx:0 },
    { op:'push', val:@global_obj },
    { op:'push', val:'output' },
    { op:'get_field' },
    { op:'call', ret_to:@block_230, num_args:1 },
  ]
};

block_230 = {
  instrs: [
    { op:'pop' },
    { op:'push', val:'\x0A' },
    { op:'push', val:@global_obj },
    { op:'push', val:'output' },
    { op:'get_field' },
    { op:'call', ret_to:@block_231, num_args:1 },
  ]
};

block_231 = {
  instrs: [
    { op:'pop' },
    { op:'push', val:$undef },
    { op:'ret' },
  ]
};

fun_229 = {
  entry:@block_228,
  num_params:1,
  num_locals:1,
};

block_232 = {
  instrs: [
    { op:'get_local', idx:0 },
    { op:'push', val:@global_obj },
    { op:'push', val:'io' },
    { op:'get_field' },
    { op:'push', val:'read_file' },
    { op:'push', val:@global_obj },
    { op:'push', val:'rt_getProp' },
    { op:'get_field' },
    { op:'call', ret_to:@block_234, num_args:2 },
  ]
};

block_234 = {
  instrs: [
    { op:'call', ret_to:@block_235, num_args:1 },
  ]
};

block_235 = {
  instrs: [
    { op:'ret' },
  ]
};

fun_233 = {
  entry:@block_232,
  num_params:1,
  num_locals:1,
};

block_0 = {
  instrs: [
    { op:'push', val:@global_obj },
    { op:'push', val:'rt_add' },
    { op:'push', val:@fun_3 },
    { op:'set_field' },
    { op:'push', val:@global_obj },
    { op:'push', val:'rt_sub' },
    { op:'push', val:@fun_20 },
    { op:'set_field' },
    { op:'push', val:@global_obj },
    { op:'push', val:'rt_not' },
    { op:'push', val:@fun_31 },
    { op:'set_field' },
    { op:'push', val:@global_obj },
    { op:'push', val:'rt_eq' },
    { op:'push', val:@fun_36 },
    { op:'set_field' },
    { op:'push', val:@global_obj },
    { op:'push', val:'rt_ne' },
    { op:'push', val:@fun_71 },
    { op:'set_field' },
    { op:'push', val:@global_obj },
    { op:'push', val:'rt_le' },
    { op:'push', val:@fun_77 },
    { op:'set_field' },
    { op:'push', val:@global_obj },
    { op:'push', val:'rt_ge' },
    { op:'push', val:@fun_101 },
    { op:'set_field' },
    { op:'push', val:@global_obj },
    { op:'push', val:'rt_in' },
    { op:'push', val:@fun_125 },
    { op:'set_field' },
    { op:'push', val:@global_obj },
    { op:'push', val:'rt_instOf' },
    { op:'push', val:@fun_136 },
    { op:'set_field' },
    { op:'push', val:@global_obj },
    { op:'push', val:'rt_getProp' },
    { op:'push', val:@fun_151 },
    { op:'set_field' },
    { op:'push', val:@global_obj },
    { op:'push', val:'rt_getElem' },
    { op:'push', val:@fun_191 },
    { op:'set_field' },
    { op:'push', val:@global_obj },
    { op:'push', val:'rt_push' },
    { op:'push', val:@fun_202 },
    { op:'set_field' },
    { op:'push', val:@global_obj },
    { op:'push', val:'io' },
    { op:'push', val:'core/io' },
    { op:'import' },
    { op:'set_field' },
    { op:'push', val:@global_obj },
    { op:'push', val:'output' },
    { op:'push', val:@fun_204 },
    { op:'set_field' },
    { op:'push', val:@global_obj },
    { op:'push', val:'print' },
    { op:'push', val:@fun_229 },
    { op:'set_field' },
    { op:'push', val:@global_obj },
    { op:'push', val:'readFile' },
    { op:'push', val:@fun_233 },
    { op:'set_field' },
    { op:'push', val:$true },
    { op:'ret' },
  ]
};

fun_1 = {
  entry:@block_0,
  num_params:0,
  num_locals:0,
};

@exports_obj;
