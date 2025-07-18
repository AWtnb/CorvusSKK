﻿--[[
	 CorvusSKK Lua拡張スクリプト


	 Cから呼ばれるLuaの関数

		辞書検索
			lua_skk_search(key, okuri)
				key : 見出し語 string
				okuri : 送り仮名 string
				戻り値 : "/<C1><;A1>/<C2><;A2>/.../<Cn><;An>/\n" or "" string
		補完
			lua_skk_complement(key)
				key : 見出し語 string
				戻り値 : "/<K1>/<K2>/.../<Kn>/\n" or "" string
		見出し語変換
			lua_skk_convert_key(key, okuri)
				key : 見出し語 string
				okuri : 送り仮名 string
				戻り値 : 変換済み文字列 string
		候補変換
			lua_skk_convert_candidate(key, candidate, okuri)
				key : 見出し語 string
				candidate : 候補 string
				okuri : 送り仮名 string
				戻り値 : 変換済み文字列 string
		逆検索
			lua_skk_reverse(candidate)
				candidate : 候補 string
				戻り値 : 見出し語 string
		辞書追加
			lua_skk_add(okuriari, key, candidate, annotation, okuri)
				okuriari : boolean (送りあり:true/送りなし:false)
				key : 見出し語 string
				candidate : 候補 string
				annotation : 注釈 string
				okuri : 送り仮名 string
				戻り値 : なし
		辞書削除
			lua_skk_delete(okuriari, key, candidate)
				okuriari : boolean (送りあり:true/送りなし:false)
				key : 見出し語 string
				candidate : 候補 string
				戻り値 : なし
		辞書保存
			lua_skk_save()
				戻り値 : なし


	Luaから呼ばれるCの関数

		ユーザー辞書検索
			crvmgr.search_user_dictionary(key, okuri)
				key : 見出し語 string
				okuri : 送り仮名 string
				戻り値 : "/<C1><;A1>/<C2><;A2>/.../<Cn><;An>/\n" or "" string
		SKK辞書検索
			crvmgr.search_skk_dictionary(key, okuri)
				key : 見出し語 string
				okuri : 送り仮名 string
				戻り値 : "/<C1><;A1>/<C2><;A2>/.../<Cn><;An>/\n" or "" string
		SKK辞書サーバー検索
			crvmgr.search_skk_server(key)
				key : 見出し語 string
				戻り値 : "/<C1><;A1>/<C2><;A2>/.../<Cn><;An>/\n" or "" string
		SKK辞書サーバー情報検索
			crvmgr.search_skk_server_info()
				戻り値 : SKK Serverプロトコル"2"の結果 バージョン番号 string
						SKK Serverプロトコル"3"の結果 ホスト名 string
		Unicodeコードポイント変換
			crvmgr.search_unicode(key)
				key : 見出し語 string
				戻り値 : "/<C1><;A1>/<C2><;A2>/.../<Cn><;An>/\n" or "" string
		JIS X 0213面区点番号変換
			crvmgr.search_jisx0213(key)
				key : 見出し語 string
				戻り値 : "/<C1><;A1>/<C2><;A2>/.../<Cn><;An>/\n" or "" string
		JIS X 0208区点番号変換
			crvmgr.search_jisx0208(key)
				key : 見出し語 string
				戻り値 : "/<C1><;A1>/<C2><;A2>/.../<Cn><;An>/\n" or "" string
		文字コード表記変換 (ASCII, JIS X 0201(片仮名, 8bit), JIS X 0213 / Unicode)
			crvmgr.search_character_code(key)
				key : 見出し語 string
				戻り値 : "/<C1><;A1>/<C2><;A2>/.../<Cn><;An>/\n" or "" string
		補完
			crvmgr.complement(key)
				key : 見出し語 string
				戻り値 : "/<K1>/<K2>/.../<Kn>/\n" or "" string
		逆検索
			crvmgr.reverse(candidate)
				candidate : 候補 string
				戻り値 : 見出し語 string
		辞書追加
			crvmgr.add(okuriari, key, candidate, annotation, okuri)
				okuriari : boolean (送りあり:true/送りなし:false)
				key : 見出し語 string
				candidate : 候補 string
				annotation : 注釈 string
				okuri : 送り仮名 string
				戻り値 : なし
		辞書削除
			crvmgr.delete(okuriari, key, candidate)
				okuriari : boolean (送りあり:true/送りなし:false)
				key : 見出し語 string
				candidate : 候補 string
				戻り値 : なし
		辞書保存
			crvmgr.save()
				戻り値 : なし


	Cから定義される変数

		バージョン (skk-version)に使用
			SKK_VERSION
				"CorvusSKK X.Y.Z" string
--]]



-- 数値変換
enable_skk_convert_num = true
-- 実行変換
enable_skk_convert_gadget = true
-- skk-ignore-dic-word
enable_skk_ignore_dic_word = false
-- skk-search-sagyo-henkaku (t:true/anything:false)
enable_skk_search_sagyo_only = true


-- 数値変換タイプ1 (全角数字)
local skk_num_type1_table = {"０", "１", "２", "３", "４", "５", "６", "７", "８", "９"}

-- 数値変換タイプ2, 3 (漢数字)
local skk_num_type3_table = {"〇", "一", "二", "三", "四", "五", "六", "七", "八", "九"}
local skk_num_type3_1k_table = {"", "十", "百", "千"}
local skk_num_type3_10k_table = {"", "万", "億", "兆", "京", "垓",
	"𥝱", "穣", "溝", "澗", "正", "載", "極", "恒河沙", "阿僧祇", "那由他", "不可思議", "無量大数"}

-- 数値変換タイプ5 (漢数字、大字)
local skk_num_type5_table = {"零", "壱", "弐", "参", "四", "五", "六", "七", "八", "九"}
local skk_num_type5_1k_table = {"", "拾", "百", "千"}
local skk_num_type5_10k_table = {"", "万", "億", "兆", "京", "垓",
	"𥝱", "穣", "溝", "澗", "正", "載", "極", "恒河沙", "阿僧祇", "那由他", "不可思議", "無量大数"}

-- 数値変換タイプ6 (独自拡張、ローマ数字)
local skk_num_type6_table_I = {"", "I", "II", "III", "IV", "V", "VI", "VII", "VIII", "IX"}
local skk_num_type6_table_X = {"", "X", "XX", "XXX", "XL", "L", "LX", "LXX", "LXXX", "XC"}
local skk_num_type6_table_C = {"", "C", "CC", "CCC", "CD", "D", "DC", "DCC", "DCCC", "CM"}
local skk_num_type6_table_M = {"", "M", "MM", "MMM"}

-- 数値変換タイプ8 (桁区切り)
local skk_num_type8_sep = ","
local skk_num_type8_sepnum = 3

-- 現在時刻
local skk_gadget_time = 0

-- skk-henkan-key
local skk_henkan_key = ""

-- skk-num-list
local skk_num_list = {}

-- おみくじ吉凶テーブル
local skk_gadget_omikuji_table = {"大吉", "吉", "中吉", "小吉", "末吉", "凶", "大凶"}

-- 元号テーブル
local skk_gadget_gengo_table = {
	{{2019,  5,  1, 1}, "れいわ",     {"令和", "R"}}, -- 2019/05/01
	{{1989,  1,  8, 1}, "へいせい",   {"平成", "H"}}, -- 1989/01/08
	{{1926, 12, 25, 1}, "しょうわ",   {"昭和", "S"}}, -- 1926/12/25
	{{1912,  7, 30, 1}, "たいしょう", {"大正", "T"}}, -- 1912/07/30
	{{1873,  1,  1, 6}, "めいじ",     {"明治", "M"}}, -- 1873/01/01(グレゴリオ暦 明治6年)
}

-- 月テーブル
local skk_gadget_month_table = {
	{"Jan", "1"}, {"Feb", "2"}, {"Mar", "3"}, {"Apr", "4"}, {"May", "5"}, {"Jun", "6"},
	{"Jul", "7"}, {"Aug", "8"}, {"Sep", "9"}, {"Oct", "10"}, {"Nov", "11"}, {"Dec", "12"}
}

-- 曜日テーブル
local skk_gadget_dayofweek_table = {
	{"Sun", "日"}, {"Mon", "月"}, {"Tue", "火"}, {"Wed", "水"}, {"Thu", "木"}, {"Fri", "金"}, {"Sat", "土"}
}

-- 単位テーブル
local skk_gadget_unit_table_org = {
	{"mile", {{"yard", 1760.0}, {"feet", 5280.0}, {"m", 1609.344}, {"km", 1.609344}}},
	{"yard", {{"feet", 3.0}, {"inch", 36.0}, {"m", 0.9144}, {"cm", 91.44}, {"mm", 914.4}}},
	{"feet", {{"inch", 12.0}, {"yard", (1.0 / 3.0)}, {"m", 0.3048}, {"cm", 30.48}, {"mm", 304.8}}},
	{"inch", {{"feet", (1.0 / 12.0)}, {"yard", (1.0 / 36.0)}, {"m", 0.0254}, {"cm", 2.54}, {"mm", 25.4}}},
	{"pound", {{"g", 453.59237}, {"ounce", 16.0}, {"grain", 7000.0}}},
	{"ounce", {{"g", 28.349523125}, {"pound", (1.0 / 16.0)}, {"grain", (7000.0 / 16.0)}}},
	{"grain", {{"mg", 64.79891}, {"g", 0.06479891}, {"pound", (1.0 / 7000.0)}, {"ounce", (16.0 / 7000.0)}}},
	{"寸", {{"mm", (1000 / 33)}, {"cm", (100 / 33)}}},
	{"尺", {{"mm", (10000 / 33)}, {"cm", (1000 / 33)}}},
	{"坪", {{"㎡", (400 / 121)}}},
	{"勺", {{"L", (2401 / 1331) / 100}, {"mL", (2401 / 1331) * 10}}},
	{"合", {{"L", (2401 / 1331) / 10}, {"mL", (2401 / 1331) * 100}}},
	{"升", {{"L", (2401 / 1331)}}},
	{"斗", {{"L", (2401 / 1331) * 10}}},
}
local skk_gadget_unit_table = {}
for i, v in ipairs(skk_gadget_unit_table_org) do
	local unit_to_table = {}
	for j, vv in ipairs(v[2]) do
		unit_to_table[vv[1]] = vv[2]
	end
	skk_gadget_unit_table[v[1]] = unit_to_table
end

-- 変数テーブル
local skk_gadget_variable_table_org = {
	{"skk-henkan-key", function() return skk_henkan_key end},
	{"skk-num-list", function() return skk_num_list end},
	{"fill-column", "70"},
	{"comment-start", "/*"},
	{"comment-end", "*/"},
}
local skk_gadget_variable_table = {}
for i, v in ipairs(skk_gadget_variable_table_org) do
	skk_gadget_variable_table[v[1]] = v[2]
end

-- (window-width)
local window_width_value = "80"

-- (window-height)
local window_height_value = "23"

-- 文字コード表記変換プレフィックス
local charcode_conv_prefix = "?"



-- 数字を漢数字に変換
local function skk_num_to_kanji(num, type_table, type_1k_table, type_10k_table)
	local ret = ""

	-- 0を付加して4の倍数の桁数にする
	num = string.rep("0", 4 - string.len(num) % 4) .. num
	local m = string.len(num) / 4

	for i = 1, m do
		for j = 1, 4 do
			local sj = string.sub(num, (i - 1) * 4 + j, (i - 1) * 4 + j)
			if (sj ~= "0") then
				-- 十の位と百の位の「一」は表記しない
				if((sj ~= "1") or (j == 1) or (j == 4)) then
					ret = ret .. type_table[tonumber(sj) + 1]
				end
				ret = ret .. type_1k_table[(4 - j) % 4 + 1]
			end
		end
		if (string.sub(num, (i - 1) * 4 + 1, (i - 1) * 4 + 4) ~= "0000") then
			ret = ret .. type_10k_table[m - i + 1]
		end
	end

	-- 0のとき
	if (ret == "") then
		ret = type_table[1]
	end

	return ret
end

-- 数値変換タイプ未定義
local function skk_num_type_n(num, len)
	return num
end

-- 数値変換タイプ1 (全角数字)
local function skk_num_type_1(num, len)
	local ret = ""

	for i = 1, len do
		ret = ret .. skk_num_type1_table[tonumber(string.sub(num, i, i)) + 1]
	end

	return ret
end

-- 数値変換タイプ2 (漢数字、位取りあり)
local function skk_num_type_2(num, len)
	local ret = ""

	for i = 1, len do
		ret = ret .. skk_num_type3_table[tonumber(string.sub(num, i, i)) + 1]
	end

	return ret
end

-- 数値変換タイプ3 (漢数字、位取りなし)
local function skk_num_type_3(num, len)
	local ret = ""

	if (len > (#skk_num_type3_10k_table * 4)) then
		ret = num
	else
		ret = skk_num_to_kanji(num, skk_num_type3_table, skk_num_type3_1k_table, skk_num_type3_10k_table)
	end

	return ret
end

-- 数値変換タイプ4 (数値再変換)
local function skk_num_type_4(num, len)
	local ret = ""

	-- ユーザー辞書検索
	ret = ret .. crvmgr.search_user_dictionary(num, "")

	-- SKK辞書検索
	ret = ret .. crvmgr.search_skk_dictionary(num, "")

	-- SKK辞書サーバー検索
	ret = ret .. crvmgr.search_skk_server(num)

	-- 余計な"/\n"を削除
	ret = string.gsub(ret, "/\n/", "/")

	-- 先頭の候補のみ
	ret = string.match(ret, "^/([^;/]+)")

	return ret
end

-- 数値変換タイプ5 (漢数字、大字)
local function skk_num_type_5(num, len)
	local ret = ""

	if (len > (#skk_num_type5_10k_table * 4)) then
		ret = num
	else
		ret = skk_num_to_kanji(num, skk_num_type5_table, skk_num_type5_1k_table, skk_num_type5_10k_table)
	end

	return ret
end

-- 数値変換タイプ6 (独自拡張、ローマ数字)
local function skk_num_type_6(num, len)
	local ret = ""
	local n = tonumber(num)

	if (n >= 1 and n <= 3999) then
		ret = skk_num_type6_table_M[((n - (n % 1000)) / 1000) + 1] ..
			skk_num_type6_table_C[(((n - (n % 100)) / 100) % 10) + 1] ..
			skk_num_type6_table_X[(((n - (n % 10)) / 10) % 10) + 1] ..
			skk_num_type6_table_I[(n % 10) + 1]
	end

	return ret
end

-- 数値変換タイプ8 (桁区切り)
local function skk_num_type_8(num, len)
	local ret = ""

	if (len % skk_num_type8_sepnum ~= 0) then
		ret = ret .. string.sub(num, 1, len % skk_num_type8_sepnum) .. skk_num_type8_sep
	end
	for i = 0, (len - len % skk_num_type8_sepnum) / skk_num_type8_sepnum do
		local sepi = len % skk_num_type8_sepnum + i * skk_num_type8_sepnum
		ret = ret .. string.sub(num, sepi + 1, sepi + skk_num_type8_sepnum) .. skk_num_type8_sep
	end
	ret = string.sub(ret, 1, string.len(ret) - string.len(skk_num_type8_sep) - 1)

	return ret
end

-- 数値変換タイプ9
local function skk_num_type_9(num, len)
	local ret = ""

	if (len == 2) then
		ret = skk_num_type1_table[tonumber(string.sub(num, 1, 1)) + 1] ..
			skk_num_type3_table[tonumber(string.sub(num, 2, 2)) + 1]
	else
		ret = num
	end

	return ret
end

-- 数値変換タイプ関数テーブル
local skk_num_type_func_table = {
	skk_num_type_1,
	skk_num_type_2,
	skk_num_type_3,
	skk_num_type_4,
	skk_num_type_5,
	skk_num_type_6,
	skk_num_type_n,
	skk_num_type_8,
	skk_num_type_9
}

-- 数値変換
local function skk_convert_num_type(num, type)
	local ret = ""
	local len = string.len(num)
	local ntype = tonumber(type)

	if ((1 <= ntype) and (ntype <= #skk_num_type_func_table)) then
		ret = skk_num_type_func_table[ntype](num, len)
	else
		ret = num
	end

	return ret
end

-- concat
local function concat(t)
	local ret = ""
	for i, v in ipairs(t) do
		ret = ret .. v
	end
	return ret
end

-- substring
local function substring(t)
	local s = t[1]
	local i = t[2]
	local j = t[3]
	return string.sub(s, i + 1, j)
end

-- make-string
local function make_string(t)
	local ret = ""
	local i = t[1]
	local c = t[2]

	if (string.sub(c, 1, 1) == "?") then
		c = string.sub(c, 2, 2)
	end

	ret = string.rep(string.sub(c, 1, 1), tonumber(i))

	return ret
end

-- string-to-number
local function string_to_number(t)
	return t[1]
end

-- string-to-char
local function string_to_char(t)
	return string.sub(t[1], 1, 1)
end

-- number-to-string
local function number_to_string(t)
	return t[1]
end

-- window-height
local function window_height(t)
	return window_height_value
end

-- window-width
local function window_width(t)
	return window_width_value
end

-- current-time
local function current_time(t)
	return tostring(skk_gadget_time)
end

-- current-time-string
local function current_time_string(t)
	local d = os.date("*t")
	return string.format("%s %s %2d %02d:%02d:%02d %04d",
		skk_gadget_dayofweek_table[d.wday][1], skk_gadget_month_table[d.month][1], d.day,
		d.hour, d.min, d.sec, d.year)
end

--[[
format-time-string

usage:

- `(format-time-string "%Y%m%d")`
- `(format-time-string "%Y年%m月%d日")`
- `(format-time-string "%Y/%m/%d")`
- `(format-time-string "%Y-%m-%d")`
- `(format-time-string "%Y%m%d_%H%M%S" (current-time))`
- `(format-time-string "%Y_%m")`
- `(format-time-string "%Y/%m/%d")`
- `(format-time-string "%Y-%m-%d")`
- `(replace-removable-zero (format-time-string "%Y年%m月%d日") "")`
- `(format-time-string "%Y%m%d")`

]]--
local function format_time_string(t)
	local format = t[1]
	local time = tonumber(t[2])

	return os.date(format, time)
end

-- car
local function car(t)
	if (#t > 0 and #t[1] > 0) then
		return t[1][1]
	end
	return ""
end

-- cdr
local function cdr(t)
	if (#t > 0 and #t[1] > 1) then
		return {table.unpack(t[1], 2)}
	end
	return ""
end

-- convert float to integer (remove suffix ".0")
local function float_to_integer(value)
	local ivalue = math.tointeger(value)
	if ivalue then
		return ivalue
	end
	return value
end

-- 1+
local function plus_1(t)
	local n1 = tonumber(t[1])

	if (not n1) then
		return ""
	end
	return float_to_integer(n1 + 1)
end

-- 1-
local function minus_1(t)
	local n1 = tonumber(t[1])

	if (not n1) then
		return ""
	end
	return float_to_integer(n1 - 1)
end

-- +
local function plus(t)
	local n = 0

	for i, v in ipairs(t) do
		local n1 = tonumber(v)
		if (not n1) then
			return ""
		end
		n = n + n1
	end

	return float_to_integer(n)
end

-- -
local function minus(t)
	local n = 0

	if (#t == 1) then
		local n1 = tonumber(t[1])
		if (not n1) then
			return ""
		end
		n = -n1
	else
		for i, v in ipairs(t) do
			local n1 = tonumber(v)
			if (not n1) then
				return ""
			end
			if (i == 1) then
				n = n1
			else
				n = n - n1
			end
		end
	end

	return float_to_integer(n)
end

-- skk-version
local function skk_version(t)
	return SKK_VERSION
end

-- skk-server-version
local function skk_server_version(t)
	local v, h = crvmgr.search_skk_server_info()

	if (v == "" or h == "") then
		return ""
	end
	return "SKK SERVER version " .. v .. "running on HOST " .. h
end

-- 西暦元号変換
--    引数    1:西暦文字列, 2:元号表記タイプ(1:漢字/2:英字頭文字), 3:変換タイプ([0-9]),
--            4:区切り, 5:末尾, 6:NOT"元"年, 7:月, 8:日
--    戻り値  変換済み文字列
local function conv_ad_to_gengo(num, gengotype, type, div, tail, not_gannen, month, day)
	local ret = ""

	local year = tonumber(num)

	for i, v in ipairs(skk_gadget_gengo_table) do
		if ((year >= v[1][1] and month == 0 and day == 0) or
			(year > v[1][1]) or
			(year == v[1][1] and month > v[1][2]) or
			(year == v[1][1] and month == v[1][2] and day >= v[1][3])) then
			ret = v[3][tonumber(gengotype)] .. div
			local gengo_year = year - v[1][1] + v[1][4]
			if ((gengo_year == 1) and (not not_gannen)) then
				ret = ret .. "元" .. tail
			else
				ret = ret .. skk_convert_num_type(tostring(gengo_year), type) .. tail
			end
			break
		end
	end

	return ret
end

-- skk-ad-to-gengo
local function skk_ad_to_gengo(t)
	local ret = ""

	local num = skk_num_list[1]
	local gengotype = t[1] + 1
	local divider = t[2]
	local tail = t[3]
	local not_gannen = t[4]

	if (divider == "nil") then
		divider = ""
	end
	if (tail == "nil") then
		tail = ""
	end
	if (not_gannen == "nil") then
		not_gannen = nil
	end

	ret = conv_ad_to_gengo(num, gengotype, "0", divider, tail, not_gannen, 0, 0)

	return ret
end

-- skk-gengo-to-ad
local function skk_gengo_to_ad(t)
	local ret = ""

	local num = skk_num_list[1]
	local head = t[1]
	local tail = t[2]

	local year = tonumber(num)

	for i, v in ipairs(skk_gadget_gengo_table) do
		if (string.sub(skk_henkan_key, 1, string.len(v[2])) == v[2]) then
			if (year >= v[1][4]) then
				local ad_year = year + v[1][1] - v[1][4]
				ret = head .. tostring(ad_year) .. tail
				break
			end
		end
	end

	return ret
end

-- skk-default-current-date
local function skk_default_current_date(t)
	local ret = ""

	if (t == nil) then
		local d = os.date("*t", skk_gadget_time)
		ret = string.format("%s年%s月%s日(%s)",
			conv_ad_to_gengo(tostring(d.year), "1", "1", "", "", false, d.month, d.day),
			skk_convert_num_type(tostring(d.month), "1"),
			skk_convert_num_type(tostring(d.day), "1"),
			skk_gadget_dayofweek_table[d.wday][2])
	else
		local d = os.date("*t", skk_gadget_time)
		local format = t[2]
		local num_type = t[3]
		local gengo = t[4]
		local gengo_index = t[5]
		local month_index = t[6]
		local dayofweek_index = t[7]
		local and_time = t[8]

		if (format == nil or format == "nil") then
			if ((and_time == nil) or (and_time == "nil")) then
				format = "%s年%s月%s日(%s)"
			else
				format = "%s年%s月%s日(%s)%s時%s分%s秒"
			end
		end

		if (num_type == "nil") then
			num_type = "0"
		end

		if (dayofweek_index == "nil") then
			dayofweek_index = "-1"
		end

		local y = ""
		if (gengo == "nil") then
			y = tostring(d.year)
		else
			y = conv_ad_to_gengo(tostring(d.year), tostring(tonumber(gengo_index) + 1),
				num_type, "", "", false, d.month, d.day)
		end

		if ((and_time == nil) or (and_time == "nil")) then
			ret = string.format(format, y,
				skk_convert_num_type(tostring(d.month), num_type),
				skk_convert_num_type(tostring(d.day), num_type),
				skk_gadget_dayofweek_table[d.wday][tonumber(dayofweek_index) + 2])
		else
			ret = string.format(format, y,
				skk_convert_num_type(tostring(d.month), num_type),
				skk_convert_num_type(tostring(d.day), num_type),
				skk_gadget_dayofweek_table[d.wday][tonumber(dayofweek_index) + 2],
				skk_convert_num_type(string.format("%02d", d.hour), num_type),
				skk_convert_num_type(string.format("%02d", d.min), num_type),
				skk_convert_num_type(string.format("%02d", d.sec), num_type))
		end
	end

	return ret
end

-- skk-current-date
local function skk_current_date(t)
	local ret = ""

	local pp_function = t[1]
	-- local format = [2]
	-- local and_time = [3]

	if (pp_function == nil) then
		ret = skk_default_current_date(nil)
	else
		ret = eval_table(pp_function)
	end

	return ret
end

-- skk-relative-date
local function skk_relative_date(t)
	local ret = ""

	local pp_function = t[1]
	-- local format = t[2]
	-- local and_time = t[3]
	local ymd = t[4]
	local diff = t[5]

	local d = os.date("*t", skk_gadget_time)

	if (ymd == ":yy") then
		d["year"] = d["year"] + tonumber(diff)
	elseif (ymd == ":mm") then
		d["month"] = d["month"] + tonumber(diff)
	elseif (ymd == ":dd") then
		d["day"] = d["day"] + tonumber(diff)
	else
	end

	local skk_gadget_time_bak = skk_gadget_time
	skk_gadget_time = os.time(d)

	if (pp_function == "nil") then
		ret = skk_default_current_date(nil)
	else
		ret = eval_table(pp_function)
	end

	skk_gadget_time = skk_gadget_time_bak

	return ret
end

-- skk-gadget-units-conversion
local function skk_gadget_units_conversion(t)
	local ret = ""

	local unit_from = t[1]
	local number = t[2]
	local unit_to = t[3]

	local value_from = skk_gadget_unit_table[unit_from]
	if (value_from) then
		local value_to = value_from[unit_to]
		if (value_to) then
			ret = tostring(float_to_integer(tonumber(number) * value_to)) .. unit_to
		end
	end

	return ret
end

-- skk-omikuji
local function skk_omikuji(t)
	return skk_gadget_omikuji_table[math.random(1, #skk_gadget_omikuji_table)]
end

-- skk-strftime
local function skk_strftime(t)
	local format = t[1]
	local unit = t[2]
	local diff = t[3]

	local skk_gadget_time_table = os.date('*t', skk_gadget_time)

	if (unit and skk_gadget_time_table[unit] and diff) then
		skk_gadget_time_table[unit] = skk_gadget_time_table[unit] + tonumber(diff)
	end

	return os.date(format, os.time(skk_gadget_time_table))
end


--[[

消しても問題ないゼロ（非数字のすぐ後ろにあるゼロ）を任意の文字に置換する

usage:

- `(replace-removable-zero "01月01日", "")`

]]--
local function replace_removable_zero(t)
	local s = t[1]
	local repl = t[2]
	if tonumber(repl) == 0 then
		return s
	end
	local f = string.gsub(s, "%D0+", function(m)
		return string.sub(m, 1, 1) .. repl
	end)
	return tostring(string.gsub(f, "^0+", repl))
end

--[[

第1引数で指定したフォーマットで日付変換する

- 引数が4つの場合は残りの3つからY年M月D日を計算する。
- 引数が3つの場合は残りの2つから「今年のM月D日」を計算する。
- 引数が2つの場合は残りの1つから「今月のD日」を計算する。
- 引数が1つだけの場合は実行時点の日時を計算する。

Yに1989年以前を指定するとWindows環境ではエラーになるようなので注意。

usage:

- `(replace-removable-zero (smart-format-day "%Y年%m月%d日（%a）" #0 #0 #0) "")`
- `(replace-removable-zero (smart-format-day "%Y年%m月%d日（%a）" #0 #0) "")`
- `(replace-removable-zero (smart-format-day "%Y年%m月%d日（%a）" #0) "")`
- `(replace-removable-zero (smart-format-day "%Y年%m月%d日（%a）") "")`

]]--
local function smart_format_day(t)
	local yy = tostring(os.date("%Y"))
	local mm = tostring(os.date("%m"))
	local dd = tostring(os.date("%d"))
	local fmt = t[1]
	if 1 < #t then
		dd = t[2]
		if 2 < #t then
			mm = t[2]
			dd = t[3]
			if 3 < #t then
				yy = t[2]
				if string.len(yy) == 2 then
					yy = "20" .. yy
				end
				mm = t[3]
				dd = t[4]
			end
		end
	end
	local ts = os.time({year=yy,month=mm,day=dd})
	return os.date(fmt, ts)
end

--[[

月と日を指定して現在の年の日付を任意のフォーマットに変換する

usage:

- `(replace-removable-zero (format-this-year "%Y年%m月%d日（%a）" #0 #0) "0")`
- `(replace-removable-zero (format-this-year "%m月%d日（%a）" #0 #0) "")`

]]--
local function format_this_year(t)
	return smart_format_day(t)
end

--[[

日を指定して現在の月の日付を任意のフォーマットに変換する

usage:

- `(replace-removable-zero (format-this-month "%Y年%m月%d日（%a）" #0) " ")`
- `(replace-removable-zero (format-this-month "%d日（%a）" #0) "")`

]]--
local function format_this_month(t)
	return smart_format_day(t)
end


--[[

元号への変換。引数が4桁の場合はyyyy0101として、6桁の場合はyyyyMM01として解釈する。

usage:

- `(gengofy #0)`

]]--
local function gengofy(t)
	local s = t[1]
	local yyyy = tonumber(string.sub(s, 1, 4))

	local mm = 1
	local dd = 1
	if 4 < string.len(s) then
		local m = nil
		if string.len(s) == 5 then
			m = tonumber(string.sub(s, 5, 5))
		else
			m = tonumber(string.sub(s, 5, 6))
		end
		if m then
			mm = m
		end
		if 6 < string.len(s) then
			local d = nil
			if string.len(s) == 7 then
				d = tonumber(string.sub(s, 7, 7))
			else
				d = tonumber(string.sub(s, 7, 8))
			end
			if d then
				dd = d
			end
		end
	end

	local gengo = nil
	local y = nil
	local suffix = ""

	for i, v in ipairs(skk_gadget_gengo_table) do
		if (
			(v[1][1] < yyyy) or
			(v[1][1] == yyyy and v[1][2] < mm) or
			(v[1][1] == yyyy and v[1][2] == mm and v[1][3] <= dd)
		) then
			gengo = v[3][1]
			y = yyyy - v[1][1] + v[1][4]
			if y == v[1][4] then
				y = "元"
			end
			break
		else
			if (
				(v[1][1] == yyyy and mm < v[1][2]) or
				(v[1][1] == yyyy and mm == v[1][2] and dd < v[1][3])
			) then
				local last = skk_gadget_gengo_table[i + 1]
				if last then
					gengo = last[3][1]
					y = yyyy - last[1][1] + last[1][4]
					suffix = string.format("(%d/%d〜 %s)", v[1][2], v[1][3], v[3][1])
					break
				end
			end
		end
	end

	if not gengo or not y then
		return s
	end

	local ret = gengo .. tostring(y) .. "年" .. suffix
	return ret
end

--[[

一番近い未来の日付を、第1引数で指定したフォーマットに変換する

- 引数が3つの場合は残りの2つから「今年のM月D日」を計算する。M月D日が実行時点から見て過去であれば翌年のM月D日を返す。
- 引数が2つの場合は第2引数から「今月のD日」を取得する。D日が実行時点から見て過去であれば翌月のD日を返す。

usage:

- `(replace-removable-zero (format-upcoming-day "%Y年%m月%d日（%a）" #0 #0) "")`
- `(replace-removable-zero (format-upcoming-day "%m月%d日（%a）" #0 #0) "")`
- `(replace-removable-zero (format-upcoming-day "%d日（%a）" #0) "")`

]]--
local function format_upcoming_day(t)
	local today = os.time({year=tostring(os.date("%Y")), month=tostring(os.date("%m")), day=tostring(os.date("%d"))})

	local fmt = t[1]
	local yyyy = tostring(os.date("%Y"))
	local MM = tostring(os.date("%m"))
	local dd = t[2]

	if 2 < #t then
		MM = t[2]
		dd = t[3]
	end

	local ts = os.time({year=yyyy,month=MM,day=dd})
	if os.difftime(ts, today) <= 0 then
		if 2 < #t then
			ts = os.time({year=tostring(tonumber(yyyy)+1),month=MM,day=dd})
		else
			ts = os.time({year=yyyy,month=tostring(tonumber(MM)+1),day=dd})
		end
	end
	return os.date(fmt, ts)
end

--[[

一番近い過去の日付を、第1引数で指定したフォーマットに変換する

- 引数が3つの場合は残りの2つから「今年のM月D日」を計算する。M月D日が実行時点から見て未来であれば前年のM月D日を返す。
- 引数が2つの場合は第2引数から「今月のD日」を取得する。D日が実行時点から見て未来であれば前月のD日を返す。

usage:

- `(replace-removable-zero (format-last-day "%Y年%m月%d日（%a）" #0 #0) "")`
- `(replace-removable-zero (format-last-day "%m月%d日（%a）" #0 #0) "")`
- `(replace-removable-zero (format-last-day "%d日（%a）" #0) "")`

--]]
local function format_last_day(t)
	local today = os.time({year=tostring(os.date("%Y")), month=tostring(os.date("%m")), day=tostring(os.date("%d"))})

	local fmt = t[1]
	local yyyy = tostring(os.date("%Y"))
	local MM = tostring(os.date("%m"))
	local dd = t[2]

	if 2 < #t then
		MM = t[2]
		dd = t[3]
	end

	local ts = os.time({year=yyyy,month=MM,day=dd})
	if os.difftime(today, ts) <= 0 then
		if 2 < #t then
			ts = os.time({year=tostring(tonumber(yyyy)-1),month=MM,day=dd})
		else
			ts = os.time({year=yyyy,month=tostring(tonumber(MM)-1),day=dd})
		end
	end
	return os.date(fmt, ts)
end

--[[

第1引数で指定したフォーマットで、第2引数の数字に対応した曜日に変換する
（月曜日＝1）

usage:

- `(format-day-of-week "（%s）" #0)`

]]--
local function format_day_of_week(t)
	local ds = {"月", "火", "水", "木", "金", "土", "日"}
	local n = (tonumber(t[2]) - 1) % 7 + 1
	return string.format(t[1], ds[n])
end

--[[

第1引数で指定したフォーマットで、第2引数の数字に対応した「一番近い未来の曜日」に変換する

usage:

- `(replace-removable-zero (format-upcoming-day-of-week "%d日（%a）" #0) "")`

]]--
local function format_upcoming_day_of_week(t)
	local fmt = t[1]
	local idx = tonumber(t[2]) % 7

	local yy = tostring(os.date("%Y"))
	local mm = tostring(os.date("%m"))
	local dd = tostring(os.date("%d"))

	for i = 1, 7, 1 do
		local ts = os.time({year=yy, month=mm, day=tostring(tonumber(dd)+i)})
		if tonumber(os.date("%w", ts)) == idx then
			return os.date(fmt, ts)
		end
	end
	return os.date(fmt, os.time())
end

--[[

第1引数で指定したフォーマットで、第2引数の数字に対応した「一番近い過去の曜日」に変換する

usage:

- `(replace-removable-zero (format-last-day-of-week "%d日（%a）" #0) "")`

]]--
local function format_last_day_of_week(t)
	local fmt = t[1]
	local idx = tonumber(t[2]) % 7

	local yy = tostring(os.date("%Y"))
	local mm = tostring(os.date("%m"))
	local dd = tostring(os.date("%d"))

	for i = 1, 7, 1 do
		local ts = os.time({year=yy, month=mm, day=tostring(tonumber(dd)-i)})
		if tonumber(os.date("%w", ts)) == idx then
			return os.date(fmt, ts)
		end
	end
	return os.date(fmt, os.time())
end


--[[

第1引数で指定したフォーマットで、第2引数の数字で指定した「N日後の日付」に変換する

usage:

- `(replace-removable-zero (skk-day-plus "%Y%m%d" #0) "")`
- `(replace-removable-zero (skk-day-plus "%Y年%m月%d日（%a）" #0) "")`

]]--
local function skk_day_plus(t)
	local fmt = t[1]
	local delta = t[2]
	local yy = tostring(os.date("%Y"))
	local mm = tostring(os.date("%m"))
	local dd = tostring(tonumber(os.date("%d")) + tonumber(delta))
	return  tostring(os.date(fmt, os.time({year=yy,month=mm,day=dd})))
end

--[[

第1引数で指定したフォーマットで、第2引数の数字で指定した「N日前の日付」に変換する

usage:

- `(replace-removable-zero (skk-day-minus "%Y%m%d" #0) "")`
- `(replace-removable-zero (skk-day-minus "%Y年%m月%d日（%a）" #0) "")`

]]--
local function skk_day_minus(t)
	local fmt = t[1]
	local delta = t[2]
	local yy = tostring(os.date("%Y"))
	local mm = tostring(os.date("%m"))
	local dd = tostring(tonumber(os.date("%d")) - tonumber(delta))
	return  tostring(os.date(fmt, os.time({year=yy,month=mm,day=dd})))
end



--[[

桁区切りのコンマを挿入する

]]--
local function ketakugiri(s)
	-- https://www.mathkuro.com/game-dev/lua-convert-number-to-currency-style-string/
	local ret = ""
	local i = 1
	s = string.reverse(s)
	while (i <= string.len(s)) do
	  ret = "," .. string.reverse(string.sub(s, i, i + 2)) .. ret
	  i = i + 3
	end

	return string.sub(ret, 2)
end

--[[

桁区切りのコンマを挿入する

usage:

- `(concat (to-comma-separated #0) "円")`

]]--
local function to_comma_separated(t)
	return ketakugiri(t[1])
end

--[[

日本語の位取りを入れる

]]--
local function kuraidori(s)
	local ret = ""
	local i = 1
	local j = 1
	s = string.reverse(s)
	while (i <= string.len(s)) do
		if j <= #skk_num_type3_10k_table then
			local quadruple = string.reverse(string.sub(s, i, i + 3))
			if quadruple ~= "0000" then
				local u = skk_num_type3_10k_table[j]
				ret = tonumber(quadruple) .. u .. ret
			end
		end
		i = i + 4
		j = j + 1
	end
	return ret
end

--[[

日本語の位取りを入れる

usage:

- `(concat (to-japanese-unit #0) "円")`

]]--
local function to_japanese_unit(t)
	return kuraidori(t[1])
end

--[[

校数への変換。
1→初（初校）、2→再（再校）とする。
第2引数で何校で校了とするか指定。校了以降は念校、念々校……として、5以上なら数値も付記する。

usage:

- `(format-proof #0 4)`
- `(concat "要" (format-proof #0 4) "ゲラ")`

]]--
local function format_proof(t)
	local count = tonumber(t[1])
	local finish = tonumber(t[2])
	if count < 1 then
		count = 1
	end
	local step = {"初", "再", "三", "四", "五" ,"六" ,"七" ,"八" ,"九"}
	local idx = ""
	local append = ""
	if count < finish then
		if count <= #step then
			idx = step[count]
		else
			idx = tostring(count)
		end
	else
		idx = "念"
		for _ = 1, (count - finish) do
			idx = idx .. "々"
		end
		if 5 < count then
			append = string.format("（%d校）", count)
		end
	end
	return idx .. "校" .. append
end

--[[

見出し変換

usage:

- `(format-book-heading #0)`

]]--
local function format_book_heading(t)
	local count = tonumber(t[1]) + 1
	local step = {"部", "章", "節", "項", "小"}
	local h = ""
	if count <= #step then
		h = step[count]
	else
		h = step[#step]
		for _ = 1, (count - #step) do
			h = h .. "々"
		end
	end
	return h .. "見出し"
end

--[[

クレジットカード請求日付変換
（前々月16日〜前月15日）

usage:

- `(format-credit-card-1 #0)`

]]--
local function format_credit_card_1(t)
	local yyyyMM = t[1]
	if string.len(yyyyMM) == 1 then
		yyyyMM = "0" .. yyyyMM
	end
	if string.len(yyyyMM) == 2 then
		yyyyMM = tostring(os.date("%Y")) .. yyyyMM
	end
	local yyyy = string.sub(yyyyMM, 1, 4)
	local MM = string.sub(yyyyMM, 5, 6)
	local nm = tonumber(MM)
	if string.len(MM) == 2 and 0 < nm and nm <= 12 then
		local mmMinus1 = (nm - 1 + 11) % 12 + 1
		local mmMinus2 = (nm - 2 + 11) % 12 + 1
		return string.format("%s_%02d月請求分_%02d16-%02d15", yyyy, MM, mmMinus2, mmMinus1)
	end
	return yyyyMM .. "_請求分_前々月16日-前月15日"
end

--[[

クレジットカード請求日付変換
（前月1日〜前月末日）

usage:

- `(format-credit-card-2 #0)`

]]--
local function format_credit_card_2(t)
	local yyyyMM = t[1]
	if string.len(yyyyMM) == 1 then
		yyyyMM = "0" .. yyyyMM
	end
	if string.len(yyyyMM) == 2 then
		yyyyMM = tostring(os.date("%Y")) .. yyyyMM
	end
	local yyyy = string.sub(yyyyMM, 1, 4)
	local MM = string.sub(yyyyMM, 5, 6)
	if string.len(MM) == 2 and 0 < tonumber(MM) and tonumber(MM) <= 12 then
		local mmMinus1 = (tonumber(MM) - 1 + 11) % 12 + 1
		return string.format("%s_%02d月請求分_%02d01-%02d%02d", yyyy, MM, mmMinus1, mmMinus1, os.date("%d", os.time({year=yyyy, month=MM, day=0})))
	end
	return yyyyMM .. "_請求分_前月1日-前月末日"
end

--[[

Markdown見出し変換

usage:

- `(format-markdown-heading #0)`

]]--
local function format_markdown_heading(t)
	local heading = ""
	local count = tonumber(t[1])
	for _ = 1, math.min(6, count) do
		heading = heading .. "#"
	end
	return heading .. " "
end


--[[

環境変数 %USERPROFILE% の展開

usage:

- `(resolve-user-profile "%s\\Desktop\\")`
- `(concat (resolve-user-profile "%s\\Desktop\\") (format-time-string "%Y%m%d_%H%M%S" (current-time)))`

]]--
local function resolve_user_profile(t)
	return string.format(t[1], os.getenv("USERPROFILE"))
end

--[[

ローマ数字に変換

https://getwebtips.net/blog/2022/7/20/python-coding-challenge-convert-integer-into-roman-numeral/

]]--
local function to_roman(i, lower)
	local values = {{1000, "M"}, {900, "CM"}, {500, "D"}, {400, "CD"}, {100, "C"}, {90, "XC"}, {50, "L"}, {40, "XL"},
					{10, "X"}, {9, "IX"}, {5, "V"}, {4, "IV"}, {1, "I"}}
	local ret = ""

	for _, val in ipairs(values) do
		local n, r = val[1], val[2]
		if lower then
			r = string.lower(r)
		end
		local q = math.floor(i / n)

		if q > 0 then
			ret = ret .. r:rep(q)
			i = i % n
		end

		if i == 0 then
			break
		end
	end

	return ret
end

--[[

ローマ数字（小文字）変換

usage:

- `(format-roman-lower #0)`

]]--
local function format_roman_lower(t)
	local i = tonumber(t[1])
	local letters = { "\u{2170}", "\u{2171}", "\u{2172}", "\u{2173}", "\u{2174}", "\u{2175}", "\u{2176}", "\u{2177}", "\u{2178}", "\u{2179}"}
	if i <= #letters then
		return letters[i]
	end
	return to_roman(i, true)
end

--[[

ローマ数字（大文字）変換

usage:


- `(format-roman-upper #0)`

]]--
local function format_roman_upper(t)
	local i = tonumber(t[1])
	local letters = { "\u{2160}", "\u{2161}", "\u{2162}", "\u{2163}", "\u{2164}", "\u{2165}", "\u{2166}", "\u{2167}", "\u{2168}", "\u{2169}"}
	if i <= #letters then
		return letters[i]
	end
	return to_roman(i, false)
end


--[[

丸数字に変換（黒対応）

]]--
local function to_circled_num(n, black)
	local letters = {
		"\u{24EA}", "\u{2460}", "\u{2461}", "\u{2462}", "\u{2463}", "\u{2464}", "\u{2465}", "\u{2466}", "\u{2467}", "\u{2468}", "\u{2469}", "\u{246A}", "\u{246B}", "\u{246C}", "\u{246D}", "\u{246E}", "\u{246F}", "\u{2470}", "\u{2471}", "\u{2472}", "\u{2473}", "\u{3251}", "\u{3252}", "\u{3253}", "\u{3254}", "\u{3255}", "\u{3256}", "\u{3257}", "\u{3258}", "\u{3259}", "\u{325A}", "\u{325B}", "\u{325C}", "\u{325D}", "\u{325E}", "\u{325F}", "\u{32B1}", "\u{32B2}", "\u{32B3}", "\u{32B4}", "\u{32B5}", "\u{32B6}", "\u{32B7}", "\u{32B8}", "\u{32B9}", "\u{32BA}", "\u{32BB}", "\u{32BC}", "\u{32BD}", "\u{32BE}", "\u{32BF}"
	}
	if black then
		letters = {
			"\u{24FF}", "\u{2776}", "\u{2777}", "\u{2778}", "\u{2779}", "\u{277A}", "\u{277B}", "\u{277C}", "\u{277D}", "\u{277E}", "\u{277F}", "\u{24EB}", "\u{24EC}", "\u{24ED}", "\u{24EE}", "\u{24EF}", "\u{24F0}", "\u{24F1}", "\u{24F2}", "\u{24F3}", "\u{24F4}"
		}
	end
	local i = n + 1
	if i <= #letters then
		return letters[i]
	end
	return string.format("(%d)", n)
end

--[[

丸数字変換

usage:


- `(format-circled-num #0)`

]]--
local function format_circled_num(t)
	return to_circled_num(t[1], false)
end

--[[

黒丸数字変換

usage:


- `(format-black-circled-num #0)`

]]--
local function format_black_circled_num(t)
	return to_circled_num(t[1], true)
end



--[[

チェックディジット計算

]]--
local function getCheckDigit(isbn12)
	local total = 0
	for i = 1, #isbn12 do
		local n = tonumber(isbn12:sub(i, i))
		if i % 2 == 0 then
			total = total + n * 3
		else
			total = total + n
		end
	end
	return (10 - (total % 10)) % 10
end


--[[

日本のISBN（9784から開始）に変換

- 5桁なら `9784641` 始まりとする
- 第2引数があればそれを区切り文字とする。 `-` の場合は `nnn-n-nnn-nnnnn-n`


usage:

- `(format-japanese-isbn #0)`
- `(format-japanese-isbn #0 "-")`

]]--
local function format_japanese_isbn(t)
	local code = tostring(t[1])
	local sep = ""
	if 1 < #t then
		sep = tostring(t[2])
	end
	if string.len(code) == 5 then
		code = "641" .. code
	end
	local code12 = "9784" .. code
	local code13 = code12 .. getCheckDigit(code12)
	return string.sub(code13, 1, 3)
		.. sep .. string.sub(code13, 4, 4)
		.. sep .. string.sub(code13, 5, 7)
		.. sep .. string.sub(code13, 8, 12)
		.. sep .. string.sub(code13, 13, 13)
end

-- 関数テーブル
local skk_gadget_func_table_org = {
	{"concat", concat},
	{"substring", substring},
	{"make-string", make_string},
	{"string-to-number", string_to_number},
	{"string-to-char", string_to_char},
	{"number-to-string", number_to_string},
	{"window-width", window_width},
	{"window-height", window_height},
	{"current-time", current_time},
	{"current-time-string", current_time_string},
	{"format-time-string", format_time_string},
	{"car", car},
	{"cdr", cdr},
	{"1+", plus_1},
	{"1-", minus_1},
	{"+", plus},
	{"-", minus},
	{"skk-version", skk_version},
	{"skk-server-version", skk_server_version},
	{"skk-ad-to-gengo", skk_ad_to_gengo},
	{"skk-gengo-to-ad", skk_gengo_to_ad},
	{"skk-default-current-date", skk_default_current_date},
	{"skk-current-date", skk_current_date},
	{"skk-relative-date", skk_relative_date},
	{"skk-gadget-units-conversion", skk_gadget_units_conversion},
	{"skk-omikuji", skk_omikuji},
	{"skk-strftime", skk_strftime},
	{"smart-format-day", smart_format_day},
	{"format-this-year", format_this_year},
	{"format-upcoming-day", format_upcoming_day},
	{"format-last-day", format_last_day},
	{"format-upcoming-day-of-week", format_upcoming_day_of_week},
	{"format-last-day-of-week", format_last_day_of_week},
	{"format-this-month", format_this_month},
	{"gengofy", gengofy},
	{"to-comma-separated", to_comma_separated},
	{"to-japanese-unit", to_japanese_unit},
	{"skk-day-plus", skk_day_plus},
	{"skk-day-minus", skk_day_minus},
	{"format-proof", format_proof},
	{"format-book-heading", format_book_heading},
	{"format-credit-card-1", format_credit_card_1},
	{"format-credit-card-2", format_credit_card_2},
	{"format-day-of-week", format_day_of_week},
	{"format-markdown-heading", format_markdown_heading},
	{"resolve-user-profile", resolve_user_profile},
	{"format-japanese-isbn", format_japanese_isbn},
	{"format-roman-lower", format_roman_lower},
	{"format-roman-upper", format_roman_upper},
	{"format-circled-num", format_circled_num},
	{"format-black-circled-num", format_black_circled_num},
	{"replace-removable-zero", replace_removable_zero},
}
local skk_gadget_func_table = {
}
for i, v in ipairs(skk_gadget_func_table_org) do
	skk_gadget_func_table[v[1]] = v[2]
end

-- 文字列パース
local function parse_string(s)
	local ret = ""
	local bsrep = "\u{f05c}"

	s = string.gsub(s, "^\"(.*)\"$", "%1")

	-- バックスラッシュ
	s = string.gsub(s, "\\\\", bsrep)
	-- 二重引用符
	s = string.gsub(s, "\\\"", "\"")
	-- 空白文字
	s = string.gsub(s, "\\s", "\x20")
	-- 制御文字など
	s = string.gsub(s, "\\[abtnvfred ]", "")
	-- 8進数表記の文字
	s = string.gsub(s, "\\[0-3][0-7][0-7]",
		function(n)
			local c =
				tonumber(string.sub(n, 2, 2)) * 64 +
				tonumber(string.sub(n, 3, 3)) * 8 +
				tonumber(string.sub(n, 4, 4))
			if (c >= 0x20 and c <= 0x7E) then
				return string.char(c)
			end
			return ""
		end)
	-- 意味なしエスケープ
	s = string.gsub(s, "\\", "")
	-- バックスラッシュ
	s = string.gsub(s, bsrep, "\\")

	ret = s

	return ret
end

-- S式をテーブル表記に変換
function convert_s_to_table(s)
	local ret = ""
	local e = ""
	local q = 0
	local d = 0
	local c = ""
	local r = ""

	for i = 1, string.len(s) do
		c = string.sub(s, i, i)
		r = string.sub(ret, -1)

		if (c == "\"" and q == 0) then
			q = 1
		elseif (c == "\"" and q == 1 and d == 0) then
			q = 0
		end

		if (q == 0) then
			if (c == "(") then
				if (ret ~= "") then
					if (r ~= "{") then
						ret = ret .. ","
					end
				end
				ret = ret .. "{"
			elseif (c == ")" or c == "\x20") then
				if (e ~= "") then
					if (r ~= "{") then
						ret = ret .. ","
					end

					e = string.gsub(e, "\"", "\\\"")
					ret = ret .. "\"" .. e .. "\""
					e = ""
				end
			else
				e = e .. c
			end

			if (c == ")") then
				ret = ret .. "}"
			end
		else
			e = e .. c
			if (c == "\\") then
				e = e .. c
				d = d ~ 1
			else
				d = 0
			end
		end
	end

	return ret
end

-- テーブル評価
function eval_table(x)
	local argtype = type(x)
	if (argtype == "table" and #x > 0) then
		if (x[1] == "lambda") then
			if (#x >= 3 and x[3]) then
				return x[3]
			else
				return ""
			end
		end

		local func = skk_gadget_func_table[x[1]]
		if (func) then
			local arg = {table.unpack(x, 2)}
			for i, v in ipairs(arg) do
				local vv = skk_gadget_variable_table[v]
				if (vv) then
					v = vv
				end
				arg[i] = eval_table(v)
			end

			return func(arg)
		end
	elseif (argtype == "function") then
		return x()
	elseif (argtype == "string") then
		return parse_string(x)
	end

	return ""
end

-- skk-ignore-dic-word
local function skk_ignore_dic_word(candidates)
	local ret = ""
	local sca = ""
	local ignore_word_table = {}

	for ca in string.gmatch(candidates, "([^/]+)") do
		local c = string.gsub(ca, ";.+", "")
		local word = string.gsub(c, "^%(%s*skk%-ignore%-dic%-word%s+\"(.+)\"%s*%)$", "%1")
		if (word ~= c) then
			ignore_word_table[word] = true
		else
			sca = sca .. "/" .. ca
		end
	end

	if (sca == candidates) then
		return candidates
	end

	for ca in string.gmatch(sca, "([^/]+)") do
		local c = string.gsub(ca, ";.+", "")
		if (not ignore_word_table[c]) then
			ret = ret .. "/" .. ca
		end
	end

	return ret
end

-- 候補全体を数値変換
local function skk_convert_num(key, candidate)
	local ret = ""
	local keytemp = key

	ret = string.gsub(candidate, "#%d+",
		function(type)
			local num = string.match(keytemp, "%d+")
			keytemp = string.gsub(keytemp, "%d+", "#", 1)
			if (num) then
				return skk_convert_num_type(num, string.sub(type, 2))
			else
				return type
			end
		end)

	return ret
end

-- 実行変換
local function skk_convert_gadget(key, candidate)

	-- skk-henkan-key
	skk_henkan_key = key

	-- skk-num-list
	skk_num_list = {}
	string.gsub(key, "%d+",
		function(n)
			table.insert(skk_num_list, n)
		end)

	-- 日付時刻
	skk_gadget_time = os.time()

	-- 乱数
	math.randomseed(skk_gadget_time)

	local f = load("return " .. convert_s_to_table(candidate))
	if (not f) then
		return candidate
	end
	return eval_table(f())
end

-- 候補変換処理
local function skk_convert_candidate(key, candidate, okuri)
	local ret = ""
	local temp = candidate

	-- xtu/xtsuで「っ」を送り仮名にしたとき送りローマ字「t」を有効にする
	if (okuri == "っ" and string.sub(key, string.len(key)) == "x") then
		return candidate
	end

	-- 数値変換
	if (enable_skk_convert_num) then
		if (string.find(key, "%d+") and string.find(temp, "#%d")) then
			temp = skk_convert_num(key, temp)
			ret = temp
		end
	end

	-- 実行変換
	if (enable_skk_convert_gadget) then
		if (string.match(temp, "^%(.+%)$")) then
			temp = skk_convert_gadget(key, temp)
			ret = temp
		end
	end

	return ret
end

-- 見出し語変換処理
local function skk_convert_key(key, okuri)
	local ret = ""

	-- xtu/xtsuで「っ」を送り仮名にしたとき送りローマ字を「t」に変換する
	if (okuri == "っ" and string.sub(key, string.len(key)) == "x") then
		return string.sub(key, 1, string.len(key) - 1) .. "t"
	end

	-- 文字コード表記変換のとき見出し語変換しない
	local cccplen = string.len(charcode_conv_prefix)
	if (cccplen < string.len(key) and string.sub(key, 1, cccplen) == charcode_conv_prefix) then
		return ""
	end

	-- 数値変換
	if (enable_skk_convert_num) then
		if (string.find(key, "%d+")) then
			ret = string.gsub(key, "%d+", "#")
		end
	end

	return ret
end

local function to_skkdict_entry(t)
	local ret = ""
	if #t < 1 then
		return ret
	end
	for i = 1, #t do
		ret = ret .. "/" .. t[i]
	end
	return ret .. "/\n"
end

local function add_prefix_to_skkdict_entry(pref, ent)
	return string.gsub(ent, "/%C", function(m)
		return "/" .. pref .. string.sub(m, 2)
	end)
end

local function from_digits(s)
	local t = {}
	if 3 < string.len(s) then
		table.insert(t, ketakugiri(s))
		if 4 < string.len(s) then
			table.insert(t, kuraidori(s))
		end
	else
		local n = tonumber(s)
		if n < 100 then
			if n <= 50 then
				table.insert(t, to_circled_num(n, false))
				if n <= 20 then
					table.insert(t, to_circled_num(n, true))
				end
			end
			table.insert(t, to_roman(n, true))
			table.insert(t, to_roman(n, false))
		end
	end
	return t
end

local function from_3digits(s)
	local t = {}

	-- Mdd
	local M = tonumber(string.sub(s, 1, 1))
	local dd = tonumber(string.sub(s, 2))
	if 0 < M and 0 < dd and dd <= 31 then
		table.insert(t, string.format("%d月%d日", M, dd))
	end

	-- MMd
	local MM = tonumber(string.sub(s, 1, 2))
	local d = tonumber(string.sub(s, 3))
	if 0 < MM and MM <= 12 and 0 < d then
			table.insert(t, string.format("%d月%d日", MM, d))
	end

	-- hmm
	local h = tonumber(string.sub(s, 1, 1))
	local mm = tonumber(string.sub(s, 2))
	if 0 < h then
		if 0 <= mm and mm < 60 then
			if mm == 0 then
				table.insert(t, string.format("午前%d時", h))
				table.insert(t, string.format("%d時", h))
			else
				table.insert(t, string.format("午前%d時%d分", h, mm))
				table.insert(t, string.format("%d時%d分", h, mm))
				if mm == 30 then
					table.insert(t, string.format("午前%d時半", h))
					table.insert(t, string.format("%d時半", h))
				end
			end
			table.insert(t, string.format("%02d:%02d", h, mm))
			table.insert(t, string.format("AM %02d:%02d", h, mm))
		end
	end

	-- hhm
	local hh = tonumber(string.sub(s, 1, 2))
	local m = tonumber(string.sub(s, 3))
	if 0 <= hh and hh <= 24 then
		if m == 0 then
			table.insert(t, string.format("%d時", hh))
		else
			table.insert(t, string.format("%d時%d分", hh, m))
		end
		if hh <= 12 then
			if hh == 12 then
				if m == 0 then
					table.insert(t, "午後0時")
					table.insert(t, "正午")
				else
					table.insert(t, string.format("午後0時%d分", m))
				end
			else
				if m == 0 then
					table.insert(t, string.format("午前%d時", hh))
				else
					table.insert(t, string.format("午前%d時%d分", hh, m))
				end
				table.insert(t, string.format("AM %02d:%02d", hh, m))
			end
		else
			if hh == 24 then
				if m == 0 then
					table.insert(t, "午前0時")
				else
					table.insert(t, string.format("午前0時%d分", m))
				end
			else
				if m == 0 then
					table.insert(t, string.format("午後%d時", (hh % 12)))
				else
					table.insert(t, string.format("午後%d時%d分", (hh % 12), m))
				end
				table.insert(t, string.format("PM %02d:%02d", (hh % 12), m))
			end
		end
		table.insert(t, string.format("%02d:%02d", hh, m))
	end

	return t
end

local function from_4digits(s)
	local t = {}

	-- hhmm
	local hh = tonumber(string.sub(s, 1, 2))
	local mm = tonumber(string.sub(s, 3))
	if 0 <= hh and hh <= 24 and 0 <= mm and mm < 60 then
		if mm == 0 then
			table.insert(t, string.format("%d時", hh))
		else
			if mm == 30 then
				table.insert(t, string.format("%d時半", hh))
			end
			table.insert(t, string.format("%d時%d分", hh, mm))
		end

		if hh <= 12 then
			if hh == 12 then
				if mm == 0 then
					table.insert(t, "午後0時")
					table.insert(t, "正午")
				else
					table.insert(t, string.format("午後0時%d分", mm))
					if mm == 30 then
						table.insert(t, string.format("午後0時半"))
					end
				end
			else
				if mm == 0 then
					table.insert(t, string.format("午前%d時", hh))
				else
					table.insert(t, string.format("午前%d時%d分", hh, mm))
					if mm == 30 then
						table.insert(t, string.format("午前%d時半", hh))
					end
				end
				table.insert(t, string.format("AM %02d:%02d", hh, mm))
			end
		else
			if hh == 24 then
				if mm == 0 then
					table.insert(t, "午前0時")
				else
					table.insert(t, string.format("午前0時%d分", mm))
					if mm == 30 then
						table.insert(t, string.format("午前0時半"))
					end
				end
			else
				if mm == 0 then
					table.insert(t, string.format("午後%d時", (hh % 12)))
				else
					table.insert(t, string.format("午後%d時%d分", (hh % 12), mm))
					if mm == 30 then
						table.insert(t, string.format("午後%d時半", (hh % 12)))
					end
				end
			end
			table.insert(t, string.format("PM %02d:%02d", (hh % 12), mm))
		end
		table.insert(t, string.format("%02d:%02d", hh, mm))
	end

	-- MMdd
	local MM = tonumber(string.sub(s, 1, 2))
	local dd = tonumber(string.sub(s, 3))
	if 0 < MM and MM <= 12 and 0 < dd and dd <= 31 then
		table.insert(t, string.format("%d月%d日", MM, dd))
	end

	-- yyyy
	local yyyy = tonumber(s)
	if skk_gadget_gengo_table[#skk_gadget_gengo_table][1][1] <= yyyy and yyyy < 2500 then
		for i, v in ipairs(skk_gadget_gengo_table) do
			if (v[1][1] <= yyyy) then
				if (v[1][1] < yyyy) then
					local y = tostring(yyyy - v[1][1] + v[1][4])
					table.insert(t, v[3][1] .. y)
				else
					local last = skk_gadget_gengo_table[i + 1]
					if last then
						local y1 = tostring(yyyy - last[1][1] + last[1][4])
						table.insert(t, last[3][1] .. y1)
					end
					table.insert(t, v[3][1] .. "元" .. string.format(";%d月%d日以降", v[1][2], v[1][3]))
				end
				break
			end
		end
	end

	return t
end

local function from_8digits(s)
	local t = {}
	local yyyy = string.sub(s, 1, 4)
	local nY = tonumber(yyyy)
	if 1000 <= nY and nY < 3000 then
		local MM = string.sub(s, 5, 6)
		local nM = tonumber(MM)
		if 0 < nM and nM <= 12 then
			local dd = string.sub(s, 7, 8)
			local nD = tonumber(dd)
			if 0 < nD and nD <= 31 then
				table.insert(t, string.format("%d年%d月%d日", yyyy, MM, dd))
				table.insert(t, string.format("%d-%02d-%02d", yyyy, MM, dd))
				table.insert(t, string.format('(concat "%02d\\057%02d\\057%02d")', yyyy, MM, dd))
			end
		end
	end
	return t
end

local function from_6digits(s)
	local t = {}
	local t8 = from_8digits("20" .. s)
	for i = 1, #t8 do
		table.insert(t, t8[i])
	end
	local yyyy = string.sub(s, 1, 4)
	local nY = tonumber(yyyy)
	if 1000 <= nY and nY < 3000 then
		local MM = string.sub(s, 5, 6)
		local nM = tonumber(MM)
		if 0 < nM and nM <= 12 then
			table.insert(t, string.format("%d年%d月", yyyy, MM))
		end
	end
	return t
end

-- 辞書検索処理
--   検索結果のフォーマットはSKK辞書の候補部分と同じ
--   "/<C1><;A1>/<C2><;A2>/.../<Cn><;An>/\n"
local function skk_search(key, okuri)
	local ret = ""

	-- ユーザー辞書検索
	ret = ret .. crvmgr.search_user_dictionary(key, okuri)

	-- SKK辞書検索
	local from_skk_dict = crvmgr.search_skk_dictionary(key, okuri)

	-- SKK辞書の結果より先に数値を変換する
	if string.match(key, "^%d+$") then

		if string.len(key) == 3 then
			local t3 = from_3digits(key)
			if 0 < #t3 then
				ret = ret .. to_skkdict_entry(t3)
			end
		end
		if string.len(key) == 4 then
			local t4 = from_4digits(key)
			if 0 < #t4 then
				ret = ret .. to_skkdict_entry(t4)
			end
		end
		if string.len(key) == 6 then
			local t6 = from_6digits(key)
			if 0 < #t6 then
				ret = ret .. to_skkdict_entry(t6)
			end
		end
		if string.len(key) == 7 then
			-- 郵便番号SKK辞書にエントリがあれば候補の先頭に追加
			if 0 < string.len(from_skk_dict) then
				local pref = string.sub(key, 1, 3) .. "-" .. string.sub(key, 4) .. " "
				ret = ret .. add_prefix_to_skkdict_entry(pref, from_skk_dict)
			end
		end
		if string.len(key) == 8 then
			local t8 = from_8digits(key)
			if 0 < #t8 then
				ret = ret .. to_skkdict_entry(t8)
			end
		end

		local td = from_digits(key)
		if 0 < #td then
			ret = ret .. to_skkdict_entry(td)
		end

	end

	-- SKK辞書の検索結果を反映
	ret = ret .. from_skk_dict

	-- 分数
	if string.match(key, "^%d+/%d+$") then
		local i = string.find(key, "/")
		local n = string.sub(key, 1, i - 1)
		local m = string.sub(key, i + 1)
		ret = ret .. to_skkdict_entry({string.format("%d分の%d", m, n)})
	end

	-- アルファベットが連続してピリオドで終わる場合は各文字を大文字にしてピリオドと半角スペースを入れる
	if string.match(key, "^[a-z]+%.") then
		local f = string.gsub(string.sub(key, 0, -2), "[a-z]", function(m)
			return string.upper(m) .. ". "
		end)
		ret = ret .. to_skkdict_entry({f})
	end

	-- 郵便番号変換（郵便番号SKK辞書は数字7桁）
	if string.match(key, "^%d%d%d%-%d%d%d%d$") then
		local k = string.gsub(key, "-", "")
		local s = crvmgr.search_skk_dictionary(k, okuri)
		if 0 < string.len(s) then
			local pref = key .. " "
			ret = ret .. add_prefix_to_skkdict_entry(pref, s)
		end
	end

	--[[
		SKK辞書サーバー検索
		- 英数・記号から始まる場合、接辞の>で終わる場合は Google 日本語入力 CGI APIへの問い合わせを除外する。
		- crvskkserv.ini で正規表現を書く方法もあるが、設定の一元管理のために init.lua で設定しておく。
	--]]
	if not string.match(key, "^[a-zA-Z0-9%p].+") then
		local tail = string.sub(key, string.len(key))
		if tail ~= ">" then
			ret = ret .. crvmgr.search_skk_server(key)
		end
	end

	if (okuri == "") then
		-- Unicodeコードポイント変換
		ret = ret .. crvmgr.search_unicode(key)

		-- JIS X 0213面区点番号変換
		ret = ret .. crvmgr.search_jisx0213(key)

		-- JIS X 0208区点番号変換
		ret = ret .. crvmgr.search_jisx0208(key)

		local cccplen = string.len(charcode_conv_prefix)
		if (cccplen < string.len(key) and string.sub(key, 1, cccplen) == charcode_conv_prefix) then
			local subkey = string.sub(key, cccplen + 1)

			-- 文字コード表記変換
			ret = ret .. crvmgr.search_character_code(subkey)
		end
	end

	-- 余計な"/\n"を削除
	ret = string.gsub(ret, "/\n/", "/")

	return ret
end



--[[

	C側から呼ばれる関数群

--]]

-- 辞書検索
function lua_skk_search(key, okuri)

	-- skk-search-sagyo-henkaku (t:true/anything:false)
	-- 「送りあり変換で送りなし候補も検索する」 → 送り仮名あり、送りローマ字なし
	if (okuri ~= "" and string.match(string.sub(key, -1), "[a-z]") == nil) then
		if (enable_skk_search_sagyo_only) then
			if (string.find("さしすせ", okuri) ~= nil) then
				okuri = ""
			end
		else
			okuri = ""
		end
	end

	local ret = skk_search(key, okuri)

	-- skk-ignore-dic-word
	if (enable_skk_ignore_dic_word) then
		ret = skk_ignore_dic_word(ret)
	end

	return ret
end

-- 補完
function lua_skk_complement(key)
	return crvmgr.complement(key)
end

-- 見出し語変換
function lua_skk_convert_key(key, okuri)
	return skk_convert_key(key, okuri)
end

-- 候補変換
function lua_skk_convert_candidate(key, candidate, okuri)
	return skk_convert_candidate(key, candidate, okuri)
end

-- 逆検索
function lua_skk_reverse(candidate)
	-- エントリの前後からスペースを取り除く
	candidate = string.gsub(candidate, "^ +", "")
	candidate = string.gsub(candidate, " +$", "")
	return crvmgr.reverse(candidate)
end


--[[

カタカナひらがなの変換テーブル

]]--
local katakana_hiragana_conversion_table = (function ()
	local katakana = "ァアィイゥウェエォオカガキギクグケゲコゴサザシジスズセゼソゾタダチヂッツヅテデトドナニヌネノハバパヒビピフブプヘベペホボポマミムメモヤャユュヨョラリルレロワヲンヴヵヶ"
	local hiragana = "ぁあぃいぅうぇえぉおかがきぎくぐけげこごさざしじすずせぜそぞただちぢっつづてでとどなにぬねのはばぱひびぴふぶぷへべぺほぼぽまみむめもやゃゆゅよょらりるれろわをんゔゕゖ"

	local table = {}
	for i = 1, #katakana, 3 do  -- UTF-8 のカタカナ・ひらがなは3バイトずつ
		local k = string.sub(katakana, i, i + 2)
		local h = string.sub(hiragana, i, i + 2)
		table[k] = h
	end
	return table
end)()

--[[

カタカナをひらがなに変換する


]]--
local function katakana_to_hiragana(s)
	local result = ""
	local i = 1
	while i <= #s do
		local char = string.sub(s, i, i + 2)  -- UTF-8 の3バイト取得
		local kata = katakana_hiragana_conversion_table[char]
		if kata then
			result = result .. kata
		else
			result = result .. char
		end
		i = i + 3
	end
	return result
end

--[[

文字列がすべてひらがなか判定する

]]--
local function is_all_hiragana_bytes(s)
	local i = 1
	local len = #s
	while i <= len do
		if len < i + 2 then
			return false
		end -- 3バイト未満で終わる場合は false

		-- UTF-8 の3バイトを取得
		local b1 = string.byte(s, i)
		local b2 = string.byte(s, i + 1)
		local b3 = string.byte(s, i + 2)

		-- ひらがなの範囲チェック
		-- https://orange-factory.com/sample/utf8/code3/e3.html#Hiragana
		local is_hiragana = (
			(b1 == 0xE3 and b2 == 0x81 and (0x81 <= b3 and b3 <= 0xBF)) or -- U+3041 〜 U+307F (ぁ〜み)
			(b1 == 0xE3 and b2 == 0x82 and (0x80 <= b3 and b3 <= 0x96)) or -- U+3080 〜 U+3096 (む〜ゖ)
			(b1 == 0xE3 and b2 == 0x83 and (b3 == 0xBC)) -- U+30FC (ー)
		)
		if not is_hiragana then
			return false
		end

		i = i + 3 -- 3バイト進める
	end
	return true
end

--[[

文字列がすべてカタカナか判定する

]]--
local function is_all_katakana_bytes(s)
	local i = 1
	local len = #s
	while i <= len do
		if len < i + 2 then
			return false
		end -- 3バイト未満で終わる場合は false

		-- UTF-8 の3バイトを取得
		local b1 = string.byte(s, i)
		local b2 = string.byte(s, i + 1)
		local b3 = string.byte(s, i + 2)

		-- カタカナの範囲チェック
		-- https://orange-factory.com/sample/utf8/code3/e3.html#Katakana
		local is_katakana = (
			(b1 == 0xE3 and b2 == 0x82 and (0xA1 <= b3 and b3 <= 0xBF)) or -- U+30A1 〜 U+30BF (ァ〜タ)
			(b1 == 0xE3 and b2 == 0x83 and (0x80 <= b3 and b3 <= 0xB6)) or -- U+30C0 〜 U+30F6 (ダ〜ヶ)
			(b1 == 0xE3 and b2 == 0x83 and b3 == 0xBC) -- U+30FC (ー)
		)

		if not is_katakana then
			return false
		end

		i = i + 3 -- 3バイト進める
	end
	return true
end


-- 辞書追加
function lua_skk_add(okuriari, key, candidate, annotation, okuri)
	--[[
	-- 例) 送りありのときユーザー辞書に登録しない
	if (okuriari) then
		return
	end
	--]]

	--[[
	-- 例) 送り仮名ブロックを登録しない
	if (okuriari) then
		okuri = ""
	end
	--]]

	--[[
	-- 例) Unicodeコードポイント変換のときユーザー辞書に登録しない
	if not (okuriari) then
		if (string.match(key, "^U%+[0-9A-F]+$") or string.match(key, "^u[0-9a-f]+$")) then
			if (string.match(key, "^U%+[0-9A-F][0-9A-F][0-9A-F][0-9A-F]$") or			-- U+XXXX
				string.match(key, "^U%+[0-9A-F][0-9A-F][0-9A-F][0-9A-F][0-9A-F]$") or	-- U+XXXXX
				string.match(key, "^U%+10[0-9A-F][0-9A-F][0-9A-F][0-9A-F]$") or			-- U+10XXXX
				string.match(key, "^u[0-9a-f][0-9a-f][0-9a-f][0-9a-f]$") or				-- uxxxx
				string.match(key, "^u[0-9a-f][0-9a-f][0-9a-f][0-9a-f][0-9a-f]$") or		-- uxxxxx
				string.match(key, "^u10[0-9a-f][0-9a-f][0-9a-f][0-9a-f]$")) then		-- u10xxxx
				return
			end
		end
	end
	--]]

	--[[
	-- 例) JIS X 0213面区点番号変換のときユーザー辞書に登録しない
	if not (okuriari) then
		if (string.match(key, "^[12]%-[0-9][0-9]%-[0-9][0-9]$")) then
			if (string.match(key, "^[12]%-0[1-9]%-0[1-9]$") or			-- [12]-01-01 - [12]-09-94
				string.match(key, "^[12]%-0[1-9]%-[1-8][0-9]$") or		-- 〃
				string.match(key, "^[12]%-0[1-9]%-9[0-4]$") or			-- 〃
				string.match(key, "^[12]%-[1-8][0-9]%-0[1-9]$") or		-- [12]-10-01 - [12]-89-94
				string.match(key, "^[12]%-[1-8][0-9]%-[1-8][0-9]$") or	-- 〃
				string.match(key, "^[12]%-[1-8][0-9]%-9[0-4]$") or		-- 〃
				string.match(key, "^[12]%-9[0-4]%-0[1-9]$") or			-- [12]-90-01 - [12]-94-94
				string.match(key, "^[12]%-9[0-4]%-[1-8][0-9]$") or		-- 〃
				string.match(key, "^[12]%-9[0-4]%-9[0-4]$")) then		-- 〃
				return
			end
		end
	end
	--]]

	--[[
	-- 例) JIS X 0208区点番号変換のときユーザー辞書に登録しない
	if not (okuriari) then
		if (string.match(key, "^[0-9][0-9]%-[0-9][0-9]$")) then
			if (string.match(key, "^0[1-9]%-0[1-9]$") or			-- 01-01 - 09-94
				string.match(key, "^0[1-9]%-[1-8][0-9]$") or		-- 〃
				string.match(key, "^0[1-9]%-9[0-4]$") or			-- 〃
				string.match(key, "^[1-8][0-9]%-0[1-9]$") or		-- 10-01 - 89-94
				string.match(key, "^[1-8][0-9]%-[1-8][0-9]$") or	-- 〃
				string.match(key, "^[1-8][0-9]%-9[0-4]$") or		-- 〃
				string.match(key, "^9[0-4]%-0[1-9]$") or			-- 90-01 - 94-94
				string.match(key, "^9[0-4]%-[1-8][0-9]$") or		-- 〃
				string.match(key, "^9[0-4]%-9[0-4]$")) then			-- 〃
				return
			end
		end
	end
	--]]

	--[[
	-- 例) 文字コード表記変換のときユーザー辞書に登録しない
	if not (okuriari) then
		local cccplen = string.len(charcode_conv_prefix)
		if (cccplen < string.len(key) and string.sub(key, 1, cccplen) == charcode_conv_prefix) then
			return
		end
	end
	--]]

	-- 数字だけなら登録しない
	if string.match(key, "^%d+$") then
		return
	end

	-- 分数形式なら登録しない
	if string.match(key, "^%d+/%d+$") then
		return
	end

	-- 郵便番号は登録しない
	if string.match(key, "^%d%d%d%-%d%d%d%d$") then
		return
	end

	-- アルファベット小文字が連続してピリオドで終わる場合は登録しない
	if string.match(key, "^[a-z]+%.") then
		return
	end

	-- エントリ先頭にスペースが含まれないようにする
	candidate = string.gsub(candidate, "^ +", "")

	-- skk-search-sagyo-henkaku を応用して、2文字以上（バイト数で言えば6以上）の送りあり変換で送り仮名なしとしても登録する
	if (
		okuri ~= "" and
		3*2 <= string.len(candidate) and
		string.match(string.sub(key, -1), "[a-z]")
	) then
		if not is_all_hiragana_bytes(candidate) then
			if (string.find("がさしすせとだでなにのはもやを", okuri) ~= nil) then
				-- 送り仮名なしの見出し語はkeyから最後のアルファベット1文字を除いたもの
				local non_okuri = string.sub(key, 1, string.len(key) - 1)
				if non_okuri ~= "" then
					crvmgr.add(false, non_okuri, candidate, annotation, "")
				end
			end
		end
	end

	-- 丸括弧つきの候補は亀甲パーレンにした候補も登録する
	if string.find(candidate, "（") and  string.find(candidate, "）") then
		local kikko = string.gsub(string.gsub(candidate, "（", "〔"), "）", "〕")
		crvmgr.add(okuriari, key, kikko, annotation, okuri)
	end

	-- アルファベットのみの単語登録
	if string.match(key, "^[A-Za-z]+$") then
		-- 例： `WHO` で `世界保健機関` と変換できるよう辞書登録したとき（大文字から始まるのが条件）、 `who` で `WHO` にも `世界保健機関` にも変換できるようにする
		if string.match(key, "^[A-Z]") then
			local low = string.lower(key)
			crvmgr.add(okuriari, low, candidate, annotation, okuri)
			crvmgr.add(okuriari, low, key, annotation, okuri)
		end

		-- 例：`April` で `エイプリル` と変換できるよう辞書登録したとき（すべてカタカナなのが条件）、 `$えいぷりる` で `april` `April` `APRIL` と変換できるようにする
		if is_all_katakana_bytes(candidate) then
			local hira = katakana_to_hiragana(candidate)
			local hira_key = "$" .. hira
			local upp = string.upper(key)
			crvmgr.add(okuriari, hira_key, upp, annotation, okuri)
			local cap = string.upper(string.sub(key, 1, 1)) .. string.sub(key, 2)
			crvmgr.add(okuriari, hira_key, cap, annotation, okuri)
			local low = string.lower(key)
			crvmgr.add(okuriari, hira_key, low, annotation, okuri)
			crvmgr.add(okuriari, hira_key, key, annotation, okuri)
		end
	end

	-- 辞書登録
	crvmgr.add(okuriari, key, candidate, annotation, okuri)

end

-- 辞書削除
function lua_skk_delete(okuriari, key, candidate)
	-- ドル記号＋ひらがなから英数への辞書登録も削除する
	if string.match(key, "^[A-Za-z]+$") then
		if is_all_katakana_bytes(candidate) then
			local hira = katakana_to_hiragana(candidate)
			local cap = string.upper(string.sub(key, 1, 1)) .. string.sub(key, 2)
			local upp = string.upper(key)
			local low = string.lower(key)
			crvmgr.delete(okuriari, "$"..hira, key)
			crvmgr.delete(okuriari, "$"..hira, cap)
			crvmgr.delete(okuriari, "$"..hira, upp)
			crvmgr.delete(okuriari, "$"..hira, low)
		end
	end
	crvmgr.delete(okuriari, key, candidate)
end

-- 辞書保存
function lua_skk_save()
	crvmgr.save()
end
