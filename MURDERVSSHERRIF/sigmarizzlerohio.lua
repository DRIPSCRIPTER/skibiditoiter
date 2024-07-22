--[[
 .____                  ________ ___.    _____                           __                
 |    |    __ _______   \_____  \\_ |___/ ____\_ __  ______ ____ _____ _/  |_  ___________ 
 |    |   |  |  \__  \   /   |   \| __ \   __\  |  \/  ___// ___\\__  \\   __\/  _ \_  __ \
 |    |___|  |  // __ \_/    |    \ \_\ \  | |  |  /\___ \\  \___ / __ \|  | (  <_> )  | \/
 |_______ \____/(____  /\_______  /___  /__| |____//____  >\___  >____  /__|  \____/|__|   
         \/          \/         \/    \/                \/     \/     \/                   
          \_Welcome to LuaObfuscator.com   (Alpha 0.10.6) ~  Much Love, Ferib 

]]--

local StrToNumber = tonumber;
local Byte = string.byte;
local Char = string.char;
local Sub = string.sub;
local Subg = string.gsub;
local Rep = string.rep;
local Concat = table.concat;
local Insert = table.insert;
local LDExp = math.ldexp;
local GetFEnv = getfenv or function()
	return _ENV;
end;
local Setmetatable = setmetatable;
local PCall = pcall;
local Select = select;
local Unpack = unpack or table.unpack;
local ToNumber = tonumber;
local function VMCall(ByteString, vmenv, ...)
	local DIP = 1;
	local repeatNext;
	ByteString = Subg(Sub(ByteString, 5), "..", function(byte)
		if (Byte(byte, 2) == 79) then
			local FlatIdent_76979 = 0;
			while true do
				if (FlatIdent_76979 == 0) then
					repeatNext = StrToNumber(Sub(byte, 1, 1));
					return "";
				end
			end
		else
			local a = Char(StrToNumber(byte, 16));
			if repeatNext then
				local b = Rep(a, repeatNext);
				repeatNext = nil;
				return b;
			else
				return a;
			end
		end
	end);
	local function gBit(Bit, Start, End)
		if End then
			local FlatIdent_69270 = 0;
			local Res;
			while true do
				if (FlatIdent_69270 == 0) then
					Res = (Bit / (2 ^ (Start - 1))) % (2 ^ (((End - 1) - (Start - 1)) + 1));
					return Res - (Res % 1);
				end
			end
		else
			local Plc = 2 ^ (Start - 1);
			return (((Bit % (Plc + Plc)) >= Plc) and 1) or 0;
		end
	end
	local function gBits8()
		local a = Byte(ByteString, DIP, DIP);
		DIP = DIP + 1;
		return a;
	end
	local function gBits16()
		local FlatIdent_6D4CB = 0;
		local a;
		local b;
		while true do
			if (FlatIdent_6D4CB == 1) then
				return (b * 256) + a;
			end
			if (FlatIdent_6D4CB == 0) then
				a, b = Byte(ByteString, DIP, DIP + 2);
				DIP = DIP + 2;
				FlatIdent_6D4CB = 1;
			end
		end
	end
	local function gBits32()
		local FlatIdent_12703 = 0;
		local a;
		local b;
		local c;
		local d;
		while true do
			if (FlatIdent_12703 == 0) then
				a, b, c, d = Byte(ByteString, DIP, DIP + 3);
				DIP = DIP + 4;
				FlatIdent_12703 = 1;
			end
			if (FlatIdent_12703 == 1) then
				return (d * 16777216) + (c * 65536) + (b * 256) + a;
			end
		end
	end
	local function gFloat()
		local FlatIdent_475BC = 0;
		local Left;
		local Right;
		local IsNormal;
		local Mantissa;
		local Exponent;
		local Sign;
		while true do
			if (FlatIdent_475BC == 3) then
				if (Exponent == 0) then
					if (Mantissa == 0) then
						return Sign * 0;
					else
						local FlatIdent_1076E = 0;
						while true do
							if (FlatIdent_1076E == 0) then
								Exponent = 1;
								IsNormal = 0;
								break;
							end
						end
					end
				elseif (Exponent == 2047) then
					return ((Mantissa == 0) and (Sign * (1 / 0))) or (Sign * NaN);
				end
				return LDExp(Sign, Exponent - 1023) * (IsNormal + (Mantissa / (2 ^ 52)));
			end
			if (FlatIdent_475BC == 1) then
				IsNormal = 1;
				Mantissa = (gBit(Right, 1, 20) * (2 ^ 32)) + Left;
				FlatIdent_475BC = 2;
			end
			if (FlatIdent_475BC == 2) then
				Exponent = gBit(Right, 21, 31);
				Sign = ((gBit(Right, 32) == 1) and -1) or 1;
				FlatIdent_475BC = 3;
			end
			if (FlatIdent_475BC == 0) then
				Left = gBits32();
				Right = gBits32();
				FlatIdent_475BC = 1;
			end
		end
	end
	local function gString(Len)
		local Str;
		if not Len then
			local FlatIdent_C460 = 0;
			while true do
				if (FlatIdent_C460 == 0) then
					Len = gBits32();
					if (Len == 0) then
						return "";
					end
					break;
				end
			end
		end
		Str = Sub(ByteString, DIP, (DIP + Len) - 1);
		DIP = DIP + Len;
		local FStr = {};
		for Idx = 1, #Str do
			FStr[Idx] = Char(Byte(Sub(Str, Idx, Idx)));
		end
		return Concat(FStr);
	end
	local gInt = gBits32;
	local function _R(...)
		return {...}, Select("#", ...);
	end
	local function Deserialize()
		local FlatIdent_104D4 = 0;
		local Instrs;
		local Functions;
		local Lines;
		local Chunk;
		local ConstCount;
		local Consts;
		while true do
			if (FlatIdent_104D4 == 1) then
				ConstCount = gBits32();
				Consts = {};
				for Idx = 1, ConstCount do
					local Type = gBits8();
					local Cons;
					if (Type == 1) then
						Cons = gBits8() ~= 0;
					elseif (Type == 2) then
						Cons = gFloat();
					elseif (Type == 3) then
						Cons = gString();
					end
					Consts[Idx] = Cons;
				end
				Chunk[3] = gBits8();
				FlatIdent_104D4 = 2;
			end
			if (2 == FlatIdent_104D4) then
				for Idx = 1, gBits32() do
					local FlatIdent_40CF = 0;
					local Descriptor;
					while true do
						if (FlatIdent_40CF == 0) then
							Descriptor = gBits8();
							if (gBit(Descriptor, 1, 1) == 0) then
								local FlatIdent_49AED = 0;
								local Type;
								local Mask;
								local Inst;
								while true do
									if (FlatIdent_49AED == 3) then
										if (gBit(Mask, 3, 3) == 1) then
											Inst[4] = Consts[Inst[4]];
										end
										Instrs[Idx] = Inst;
										break;
									end
									if (FlatIdent_49AED == 1) then
										Inst = {gBits16(),gBits16(),nil,nil};
										if (Type == 0) then
											Inst[3] = gBits16();
											Inst[4] = gBits16();
										elseif (Type == 1) then
											Inst[3] = gBits32();
										elseif (Type == 2) then
											Inst[3] = gBits32() - (2 ^ 16);
										elseif (Type == 3) then
											Inst[3] = gBits32() - (2 ^ 16);
											Inst[4] = gBits16();
										end
										FlatIdent_49AED = 2;
									end
									if (FlatIdent_49AED == 2) then
										if (gBit(Mask, 1, 1) == 1) then
											Inst[2] = Consts[Inst[2]];
										end
										if (gBit(Mask, 2, 2) == 1) then
											Inst[3] = Consts[Inst[3]];
										end
										FlatIdent_49AED = 3;
									end
									if (FlatIdent_49AED == 0) then
										Type = gBit(Descriptor, 2, 3);
										Mask = gBit(Descriptor, 4, 6);
										FlatIdent_49AED = 1;
									end
								end
							end
							break;
						end
					end
				end
				for Idx = 1, gBits32() do
					Functions[Idx - 1] = Deserialize();
				end
				return Chunk;
			end
			if (FlatIdent_104D4 == 0) then
				Instrs = {};
				Functions = {};
				Lines = {};
				Chunk = {Instrs,Functions,nil,Lines};
				FlatIdent_104D4 = 1;
			end
		end
	end
	local function Wrap(Chunk, Upvalues, Env)
		local Instr = Chunk[1];
		local Proto = Chunk[2];
		local Params = Chunk[3];
		return function(...)
			local Instr = Instr;
			local Proto = Proto;
			local Params = Params;
			local _R = _R;
			local VIP = 1;
			local Top = -1;
			local Vararg = {};
			local Args = {...};
			local PCount = Select("#", ...) - 1;
			local Lupvals = {};
			local Stk = {};
			for Idx = 0, PCount do
				if (Idx >= Params) then
					Vararg[Idx - Params] = Args[Idx + 1];
				else
					Stk[Idx] = Args[Idx + 1];
				end
			end
			local Varargsz = (PCount - Params) + 1;
			local Inst;
			local Enum;
			while true do
				local FlatIdent_12544 = 0;
				while true do
					if (FlatIdent_12544 == 0) then
						Inst = Instr[VIP];
						Enum = Inst[1];
						FlatIdent_12544 = 1;
					end
					if (FlatIdent_12544 == 1) then
						if (Enum <= 51) then
							if (Enum <= 25) then
								if (Enum <= 12) then
									if (Enum <= 5) then
										if (Enum <= 2) then
											if (Enum <= 0) then
												Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
											elseif (Enum == 1) then
												Env[Inst[3]] = Stk[Inst[2]];
											else
												local B;
												local A;
												Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												A = Inst[2];
												B = Stk[Inst[3]];
												Stk[A + 1] = B;
												Stk[A] = B[Inst[4]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Stk[Inst[3]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												A = Inst[2];
												Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Stk[Inst[3]];
											end
										elseif (Enum <= 3) then
											local A;
											Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Inst[3];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											A = Inst[2];
											Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
											VIP = VIP + 1;
											Inst = Instr[VIP];
											if (Stk[Inst[2]] == Inst[4]) then
												VIP = VIP + 1;
											else
												VIP = Inst[3];
											end
										elseif (Enum == 4) then
											local FlatIdent_74348 = 0;
											local A;
											while true do
												if (FlatIdent_74348 == 7) then
													Inst = Instr[VIP];
													A = Inst[2];
													Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
													FlatIdent_74348 = 8;
												end
												if (FlatIdent_74348 == 3) then
													Inst = Instr[VIP];
													Stk[Inst[2]] = Upvalues[Inst[3]];
													VIP = VIP + 1;
													FlatIdent_74348 = 4;
												end
												if (FlatIdent_74348 == 5) then
													Inst = Instr[VIP];
													Stk[Inst[2]] = Upvalues[Inst[3]];
													VIP = VIP + 1;
													FlatIdent_74348 = 6;
												end
												if (FlatIdent_74348 == 2) then
													Inst = Instr[VIP];
													Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
													VIP = VIP + 1;
													FlatIdent_74348 = 3;
												end
												if (FlatIdent_74348 == 9) then
													VIP = VIP + 1;
													Inst = Instr[VIP];
													do
														return;
													end
													break;
												end
												if (FlatIdent_74348 == 1) then
													Inst = Instr[VIP];
													Stk[Inst[2]] = Env[Inst[3]];
													VIP = VIP + 1;
													FlatIdent_74348 = 2;
												end
												if (FlatIdent_74348 == 0) then
													A = nil;
													Stk[Inst[2]] = Upvalues[Inst[3]];
													VIP = VIP + 1;
													FlatIdent_74348 = 1;
												end
												if (FlatIdent_74348 == 6) then
													Inst = Instr[VIP];
													Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
													VIP = VIP + 1;
													FlatIdent_74348 = 7;
												end
												if (FlatIdent_74348 == 8) then
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
													FlatIdent_74348 = 9;
												end
												if (FlatIdent_74348 == 4) then
													Inst = Instr[VIP];
													Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
													VIP = VIP + 1;
													FlatIdent_74348 = 5;
												end
											end
										else
											Stk[Inst[2]] = not Stk[Inst[3]];
										end
									elseif (Enum <= 8) then
										if (Enum <= 6) then
											Stk[Inst[2]] = Stk[Inst[3]] * Inst[4];
										elseif (Enum == 7) then
											Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Env[Inst[3]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											if (Stk[Inst[2]] == Stk[Inst[4]]) then
												VIP = VIP + 1;
											else
												VIP = Inst[3];
											end
										else
											local A = Inst[2];
											Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
										end
									elseif (Enum <= 10) then
										if (Enum == 9) then
											do
												return Stk[Inst[2]];
											end
										elseif (Inst[2] < Stk[Inst[4]]) then
											VIP = VIP + 1;
										else
											VIP = Inst[3];
										end
									elseif (Enum > 11) then
										Stk[Inst[2]] = Stk[Inst[3]] + Inst[4];
									else
										local A = Inst[2];
										local Results = {Stk[A](Unpack(Stk, A + 1, Inst[3]))};
										local Edx = 0;
										for Idx = A, Inst[4] do
											Edx = Edx + 1;
											Stk[Idx] = Results[Edx];
										end
									end
								elseif (Enum <= 18) then
									if (Enum <= 15) then
										if (Enum <= 13) then
											local K;
											local B;
											Stk[Inst[2]] = Upvalues[Inst[3]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Inst[3];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											B = Inst[3];
											K = Stk[B];
											for Idx = B + 1, Inst[4] do
												K = K .. Stk[Idx];
											end
											Stk[Inst[2]] = K;
											VIP = VIP + 1;
											Inst = Instr[VIP];
											if (Stk[Inst[2]] == Stk[Inst[4]]) then
												VIP = VIP + 1;
											else
												VIP = Inst[3];
											end
										elseif (Enum == 14) then
											local FlatIdent_28F1 = 0;
											local B;
											local A;
											while true do
												if (FlatIdent_28F1 == 6) then
													if (Inst[2] < Stk[Inst[4]]) then
														VIP = VIP + 1;
													else
														VIP = Inst[3];
													end
													break;
												end
												if (FlatIdent_28F1 == 3) then
													VIP = VIP + 1;
													Inst = Instr[VIP];
													A = Inst[2];
													FlatIdent_28F1 = 4;
												end
												if (FlatIdent_28F1 == 0) then
													B = nil;
													A = nil;
													A = Inst[2];
													FlatIdent_28F1 = 1;
												end
												if (FlatIdent_28F1 == 2) then
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]] = Inst[3];
													FlatIdent_28F1 = 3;
												end
												if (FlatIdent_28F1 == 5) then
													Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													FlatIdent_28F1 = 6;
												end
												if (FlatIdent_28F1 == 1) then
													B = Stk[Inst[3]];
													Stk[A + 1] = B;
													Stk[A] = B[Inst[4]];
													FlatIdent_28F1 = 2;
												end
												if (4 == FlatIdent_28F1) then
													Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
													VIP = VIP + 1;
													Inst = Instr[VIP];
													FlatIdent_28F1 = 5;
												end
											end
										else
											local FlatIdent_47ABB = 0;
											local B;
											local A;
											while true do
												if (FlatIdent_47ABB == 7) then
													Stk[A + 1] = B;
													Stk[A] = B[Inst[4]];
													break;
												end
												if (FlatIdent_47ABB == 0) then
													B = nil;
													A = nil;
													Stk[Inst[2]] = Env[Inst[3]];
													VIP = VIP + 1;
													FlatIdent_47ABB = 1;
												end
												if (FlatIdent_47ABB == 1) then
													Inst = Instr[VIP];
													Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													FlatIdent_47ABB = 2;
												end
												if (6 == FlatIdent_47ABB) then
													VIP = VIP + 1;
													Inst = Instr[VIP];
													A = Inst[2];
													B = Stk[Inst[3]];
													FlatIdent_47ABB = 7;
												end
												if (FlatIdent_47ABB == 4) then
													Inst = Instr[VIP];
													Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													FlatIdent_47ABB = 5;
												end
												if (FlatIdent_47ABB == 3) then
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]] = Env[Inst[3]];
													VIP = VIP + 1;
													FlatIdent_47ABB = 4;
												end
												if (FlatIdent_47ABB == 2) then
													Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]][Inst[3]] = Inst[4];
													FlatIdent_47ABB = 3;
												end
												if (FlatIdent_47ABB == 5) then
													Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
													VIP = VIP + 1;
													Inst = Instr[VIP];
													Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
													FlatIdent_47ABB = 6;
												end
											end
										end
									elseif (Enum <= 16) then
										Stk[Inst[2]] = Wrap(Proto[Inst[3]], nil, Env);
									elseif (Enum > 17) then
										local B = Inst[3];
										local K = Stk[B];
										for Idx = B + 1, Inst[4] do
											K = K .. Stk[Idx];
										end
										Stk[Inst[2]] = K;
									else
										local FlatIdent_21DDC = 0;
										local Results;
										local Edx;
										local Limit;
										local B;
										local A;
										while true do
											if (FlatIdent_21DDC == 2) then
												VIP = VIP + 1;
												Inst = Instr[VIP];
												A = Inst[2];
												FlatIdent_21DDC = 3;
											end
											if (FlatIdent_21DDC == 0) then
												Results = nil;
												Edx = nil;
												Results, Limit = nil;
												FlatIdent_21DDC = 1;
											end
											if (FlatIdent_21DDC == 7) then
												A = Inst[2];
												Results = {Stk[A](Unpack(Stk, A + 1, Top))};
												Edx = 0;
												FlatIdent_21DDC = 8;
											end
											if (FlatIdent_21DDC == 9) then
												VIP = Inst[3];
												break;
											end
											if (FlatIdent_21DDC == 4) then
												VIP = VIP + 1;
												Inst = Instr[VIP];
												A = Inst[2];
												FlatIdent_21DDC = 5;
											end
											if (FlatIdent_21DDC == 1) then
												B = nil;
												A = nil;
												Stk[Inst[2]] = Upvalues[Inst[3]];
												FlatIdent_21DDC = 2;
											end
											if (8 == FlatIdent_21DDC) then
												for Idx = A, Inst[4] do
													local FlatIdent_21297 = 0;
													while true do
														if (FlatIdent_21297 == 0) then
															Edx = Edx + 1;
															Stk[Idx] = Results[Edx];
															break;
														end
													end
												end
												VIP = VIP + 1;
												Inst = Instr[VIP];
												FlatIdent_21DDC = 9;
											end
											if (FlatIdent_21DDC == 5) then
												Results, Limit = _R(Stk[A](Stk[A + 1]));
												Top = (Limit + A) - 1;
												Edx = 0;
												FlatIdent_21DDC = 6;
											end
											if (FlatIdent_21DDC == 3) then
												B = Stk[Inst[3]];
												Stk[A + 1] = B;
												Stk[A] = B[Inst[4]];
												FlatIdent_21DDC = 4;
											end
											if (FlatIdent_21DDC == 6) then
												for Idx = A, Top do
													local FlatIdent_32BB2 = 0;
													while true do
														if (FlatIdent_32BB2 == 0) then
															Edx = Edx + 1;
															Stk[Idx] = Results[Edx];
															break;
														end
													end
												end
												VIP = VIP + 1;
												Inst = Instr[VIP];
												FlatIdent_21DDC = 7;
											end
										end
									end
								elseif (Enum <= 21) then
									if (Enum <= 19) then
										Env[Inst[3]] = Stk[Inst[2]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Env[Inst[3]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]][Inst[3]] = Inst[4];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Env[Inst[3]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]][Inst[3]] = Inst[4];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Env[Inst[3]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]][Inst[3]] = Inst[4];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Env[Inst[3]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]][Inst[3]] = Inst[4];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Env[Inst[3]];
									elseif (Enum > 20) then
										local FlatIdent_91608 = 0;
										local A;
										while true do
											if (FlatIdent_91608 == 0) then
												A = nil;
												Stk[Inst[2]] = Inst[3];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												FlatIdent_91608 = 1;
											end
											if (FlatIdent_91608 == 2) then
												Stk[Inst[2]] = Upvalues[Inst[3]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
												FlatIdent_91608 = 3;
											end
											if (FlatIdent_91608 == 3) then
												VIP = VIP + 1;
												Inst = Instr[VIP];
												if Stk[Inst[2]] then
													VIP = VIP + 1;
												else
													VIP = Inst[3];
												end
												break;
											end
											if (FlatIdent_91608 == 1) then
												A = Inst[2];
												Stk[A](Stk[A + 1]);
												VIP = VIP + 1;
												Inst = Instr[VIP];
												FlatIdent_91608 = 2;
											end
										end
									else
										local B = Stk[Inst[4]];
										if not B then
											VIP = VIP + 1;
										else
											Stk[Inst[2]] = B;
											VIP = Inst[3];
										end
									end
								elseif (Enum <= 23) then
									if (Enum > 22) then
										local A = Inst[2];
										do
											return Unpack(Stk, A, A + Inst[3]);
										end
									else
										Stk[Inst[2]] = Inst[3] ^ Stk[Inst[4]];
									end
								elseif (Enum == 24) then
									Stk[Inst[2]] = Env[Inst[3]];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									if (Stk[Inst[2]] ~= Stk[Inst[4]]) then
										VIP = VIP + 1;
									else
										VIP = Inst[3];
									end
								elseif (Stk[Inst[2]] < Stk[Inst[4]]) then
									VIP = VIP + 1;
								else
									VIP = Inst[3];
								end
							elseif (Enum <= 38) then
								if (Enum <= 31) then
									if (Enum <= 28) then
										if (Enum <= 26) then
											local A;
											Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Inst[3];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Inst[3];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Inst[3];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											A = Inst[2];
											Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Env[Inst[3]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]][Inst[3]] = Inst[4];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Env[Inst[3]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]][Inst[3]] = Inst[4];
										elseif (Enum == 27) then
											local Results;
											local Edx;
											local Results, Limit;
											local B;
											local A;
											Stk[Inst[2]] = Upvalues[Inst[3]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											A = Inst[2];
											B = Stk[Inst[3]];
											Stk[A + 1] = B;
											Stk[A] = B[Inst[4]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											A = Inst[2];
											Results, Limit = _R(Stk[A](Stk[A + 1]));
											Top = (Limit + A) - 1;
											Edx = 0;
											for Idx = A, Top do
												local FlatIdent_6D68E = 0;
												while true do
													if (FlatIdent_6D68E == 0) then
														Edx = Edx + 1;
														Stk[Idx] = Results[Edx];
														break;
													end
												end
											end
											VIP = VIP + 1;
											Inst = Instr[VIP];
											A = Inst[2];
											Results = {Stk[A](Unpack(Stk, A + 1, Top))};
											Edx = 0;
											for Idx = A, Inst[4] do
												Edx = Edx + 1;
												Stk[Idx] = Results[Edx];
											end
											VIP = VIP + 1;
											Inst = Instr[VIP];
											VIP = Inst[3];
										else
											local K;
											local B;
											local A;
											Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Env[Inst[3]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Upvalues[Inst[3]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											A = Inst[2];
											Stk[A] = Stk[A](Stk[A + 1]);
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Env[Inst[3]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Upvalues[Inst[3]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											A = Inst[2];
											Stk[A] = Stk[A](Stk[A + 1]);
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Stk[Inst[3]] - Stk[Inst[4]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											A = Inst[2];
											Stk[A] = Stk[A](Stk[A + 1]);
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Upvalues[Inst[3]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Inst[3];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Upvalues[Inst[3]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Inst[3];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Env[Inst[3]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Upvalues[Inst[3]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											A = Inst[2];
											B = Stk[Inst[3]];
											Stk[A + 1] = B;
											Stk[A] = B[Inst[4]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Inst[3];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											A = Inst[2];
											Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Inst[3];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											A = Inst[2];
											Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Inst[3];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Stk[Inst[3]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											B = Inst[3];
											K = Stk[B];
											for Idx = B + 1, Inst[4] do
												K = K .. Stk[Idx];
											end
											Stk[Inst[2]] = K;
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											VIP = Inst[3];
										end
									elseif (Enum <= 29) then
										local A = Inst[2];
										local B = Stk[Inst[3]];
										Stk[A + 1] = B;
										Stk[A] = B[Inst[4]];
									elseif (Enum > 30) then
										local FlatIdent_4A248 = 0;
										local A;
										while true do
											if (FlatIdent_4A248 == 4) then
												Inst = Instr[VIP];
												Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												FlatIdent_4A248 = 5;
											end
											if (0 == FlatIdent_4A248) then
												A = nil;
												Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												FlatIdent_4A248 = 1;
											end
											if (5 == FlatIdent_4A248) then
												Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Inst[3];
												break;
											end
											if (FlatIdent_4A248 == 3) then
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Upvalues[Inst[3]];
												VIP = VIP + 1;
												FlatIdent_4A248 = 4;
											end
											if (FlatIdent_4A248 == 1) then
												Stk[Inst[2]] = Inst[3];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												A = Inst[2];
												FlatIdent_4A248 = 2;
											end
											if (FlatIdent_4A248 == 2) then
												Stk[A] = Stk[A](Stk[A + 1]);
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Stk[Inst[3]];
												FlatIdent_4A248 = 3;
											end
										end
									else
										local A = Inst[2];
										Stk[A] = Stk[A]();
									end
								elseif (Enum <= 34) then
									if (Enum <= 32) then
										local A = Inst[2];
										local Cls = {};
										for Idx = 1, #Lupvals do
											local List = Lupvals[Idx];
											for Idz = 0, #List do
												local FlatIdent_957A4 = 0;
												local Upv;
												local NStk;
												local DIP;
												while true do
													if (FlatIdent_957A4 == 0) then
														Upv = List[Idz];
														NStk = Upv[1];
														FlatIdent_957A4 = 1;
													end
													if (FlatIdent_957A4 == 1) then
														DIP = Upv[2];
														if ((NStk == Stk) and (DIP >= A)) then
															Cls[DIP] = NStk[DIP];
															Upv[1] = Cls;
														end
														break;
													end
												end
											end
										end
									elseif (Enum == 33) then
										local B;
										local A;
										Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										A = Inst[2];
										B = Stk[Inst[3]];
										Stk[A + 1] = B;
										Stk[A] = B[Inst[4]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Inst[3];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										A = Inst[2];
										Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
										VIP = VIP + 1;
										Inst = Instr[VIP];
										if Stk[Inst[2]] then
											VIP = VIP + 1;
										else
											VIP = Inst[3];
										end
									else
										local FlatIdent_7126B = 0;
										local B;
										local A;
										while true do
											if (FlatIdent_7126B == 1) then
												Inst = Instr[VIP];
												A = Inst[2];
												B = Stk[Inst[3]];
												Stk[A + 1] = B;
												FlatIdent_7126B = 2;
											end
											if (FlatIdent_7126B == 0) then
												B = nil;
												A = nil;
												Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
												VIP = VIP + 1;
												FlatIdent_7126B = 1;
											end
											if (FlatIdent_7126B == 2) then
												Stk[A] = B[Inst[4]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Inst[3];
												FlatIdent_7126B = 3;
											end
											if (FlatIdent_7126B == 4) then
												VIP = VIP + 1;
												Inst = Instr[VIP];
												if Stk[Inst[2]] then
													VIP = VIP + 1;
												else
													VIP = Inst[3];
												end
												break;
											end
											if (FlatIdent_7126B == 3) then
												VIP = VIP + 1;
												Inst = Instr[VIP];
												A = Inst[2];
												Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
												FlatIdent_7126B = 4;
											end
										end
									end
								elseif (Enum <= 36) then
									if (Enum > 35) then
										local A = Inst[2];
										local Results = {Stk[A](Stk[A + 1])};
										local Edx = 0;
										for Idx = A, Inst[4] do
											Edx = Edx + 1;
											Stk[Idx] = Results[Edx];
										end
									else
										local A;
										Stk[Inst[2]] = Stk[Inst[3]] * Inst[4];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										A = Inst[2];
										Stk[A] = Stk[A](Stk[A + 1]);
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Env[Inst[3]] = Stk[Inst[2]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Env[Inst[3]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										if (Inst[2] < Stk[Inst[4]]) then
											VIP = VIP + 1;
										else
											VIP = Inst[3];
										end
									end
								elseif (Enum == 37) then
									local A;
									Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]] = Upvalues[Inst[3]];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]] = Upvalues[Inst[3]];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									A = Inst[2];
									Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]] = Env[Inst[3]];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									A = Inst[2];
									Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]] = Stk[Inst[3]] - Stk[Inst[4]];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									if (Stk[Inst[2]] < Stk[Inst[4]]) then
										VIP = VIP + 1;
									else
										VIP = Inst[3];
									end
								else
									local FlatIdent_89562 = 0;
									local A;
									while true do
										if (FlatIdent_89562 == 5) then
											Inst = Instr[VIP];
											if Stk[Inst[2]] then
												VIP = VIP + 1;
											else
												VIP = Inst[3];
											end
											break;
										end
										if (4 == FlatIdent_89562) then
											Inst = Instr[VIP];
											A = Inst[2];
											Stk[A] = Stk[A](Stk[A + 1]);
											VIP = VIP + 1;
											FlatIdent_89562 = 5;
										end
										if (FlatIdent_89562 == 3) then
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
											VIP = VIP + 1;
											FlatIdent_89562 = 4;
										end
										if (FlatIdent_89562 == 2) then
											Stk[Inst[2]] = Env[Inst[3]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Upvalues[Inst[3]];
											FlatIdent_89562 = 3;
										end
										if (FlatIdent_89562 == 1) then
											A = Inst[2];
											Stk[A](Stk[A + 1]);
											VIP = VIP + 1;
											Inst = Instr[VIP];
											FlatIdent_89562 = 2;
										end
										if (FlatIdent_89562 == 0) then
											A = nil;
											Stk[Inst[2]] = Inst[3];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											FlatIdent_89562 = 1;
										end
									end
								end
							elseif (Enum <= 44) then
								if (Enum <= 41) then
									if (Enum <= 39) then
										local FlatIdent_B1F4 = 0;
										local A;
										while true do
											if (FlatIdent_B1F4 == 5) then
												Inst = Instr[VIP];
												Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Upvalues[Inst[3]];
												VIP = VIP + 1;
												FlatIdent_B1F4 = 6;
											end
											if (FlatIdent_B1F4 == 8) then
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Inst[3];
												break;
											end
											if (FlatIdent_B1F4 == 3) then
												Inst = Instr[VIP];
												Stk[Inst[2]] = Upvalues[Inst[3]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Stk[Inst[3]] + Stk[Inst[4]];
												VIP = VIP + 1;
												FlatIdent_B1F4 = 4;
											end
											if (FlatIdent_B1F4 == 0) then
												A = nil;
												Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
												VIP = VIP + 1;
												FlatIdent_B1F4 = 1;
											end
											if (2 == FlatIdent_B1F4) then
												Inst = Instr[VIP];
												Stk[Inst[2]] = Stk[Inst[3]] * Stk[Inst[4]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Stk[Inst[3]] + Stk[Inst[4]];
												VIP = VIP + 1;
												FlatIdent_B1F4 = 3;
											end
											if (FlatIdent_B1F4 == 4) then
												Inst = Instr[VIP];
												Stk[Inst[2]] = Upvalues[Inst[3]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Env[Inst[3]];
												VIP = VIP + 1;
												FlatIdent_B1F4 = 5;
											end
											if (FlatIdent_B1F4 == 1) then
												Inst = Instr[VIP];
												Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Upvalues[Inst[3]];
												VIP = VIP + 1;
												FlatIdent_B1F4 = 2;
											end
											if (7 == FlatIdent_B1F4) then
												Inst = Instr[VIP];
												Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												A = Inst[2];
												Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
												FlatIdent_B1F4 = 8;
											end
											if (FlatIdent_B1F4 == 6) then
												Inst = Instr[VIP];
												Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
												VIP = VIP + 1;
												FlatIdent_B1F4 = 7;
											end
										end
									elseif (Enum > 40) then
										if (Stk[Inst[2]] == Stk[Inst[4]]) then
											VIP = VIP + 1;
										else
											VIP = Inst[3];
										end
									else
										Stk[Inst[2]] = Stk[Inst[3]];
									end
								elseif (Enum <= 42) then
									do
										return;
									end
								elseif (Enum == 43) then
									local K;
									local B;
									local A;
									Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]] = Inst[3];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									A = Inst[2];
									Stk[A] = Stk[A](Stk[A + 1]);
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]] = Env[Inst[3]];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]] = Inst[3];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									A = Inst[2];
									Stk[A] = Stk[A](Stk[A + 1]);
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]] = Upvalues[Inst[3]];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]] = Upvalues[Inst[3]];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]] = Env[Inst[3]];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]] = Inst[3];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]] = Inst[3];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]] = Inst[3];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]] = Inst[3];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									A = Inst[2];
									Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]] = Env[Inst[3]];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]] = Inst[3];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]] = Inst[3];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]] = Inst[3];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									A = Inst[2];
									Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]][Inst[3]] = Inst[4];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]][Inst[3]] = Inst[4];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]] = Env[Inst[3]];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]] = Inst[3];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]] = Inst[3];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]] = Inst[3];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]] = Inst[3];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									A = Inst[2];
									Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]] = Env[Inst[3]];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]] = Inst[3];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]] = Inst[3];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]] = Inst[3];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]] = Inst[3];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									A = Inst[2];
									Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]] = Env[Inst[3]];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]][Inst[3]] = Inst[4];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]] = Env[Inst[3]];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]] = Inst[3];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]] = Inst[3];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]] = Inst[3];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									A = Inst[2];
									Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]][Inst[3]] = Inst[4];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]] = Env[Inst[3]];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]] = Inst[3];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]] = Upvalues[Inst[3]];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									B = Inst[3];
									K = Stk[B];
									for Idx = B + 1, Inst[4] do
										K = K .. Stk[Idx];
									end
									Stk[Inst[2]] = K;
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]][Inst[3]] = Inst[4];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									for Idx = Inst[2], Inst[3] do
										Stk[Idx] = nil;
									end
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]] = Upvalues[Inst[3]];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									A = Inst[2];
									B = Stk[Inst[3]];
									Stk[A + 1] = B;
									Stk[A] = B[Inst[4]];
								else
									local A;
									Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]] = Stk[Inst[3]];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									A = Inst[2];
									Stk[A] = Stk[A](Stk[A + 1]);
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]] = Stk[Inst[3]];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									if not Stk[Inst[2]] then
										VIP = VIP + 1;
									else
										VIP = Inst[3];
									end
								end
							elseif (Enum <= 47) then
								if (Enum <= 45) then
									VIP = Inst[3];
								elseif (Enum > 46) then
									local K;
									local B;
									local A;
									A = Inst[2];
									B = Stk[Inst[3]];
									Stk[A + 1] = B;
									Stk[A] = B[Inst[4]];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]] = Upvalues[Inst[3]];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]] = Inst[3];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									B = Inst[3];
									K = Stk[B];
									for Idx = B + 1, Inst[4] do
										K = K .. Stk[Idx];
									end
									Stk[Inst[2]] = K;
									VIP = VIP + 1;
									Inst = Instr[VIP];
									A = Inst[2];
									Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
									VIP = VIP + 1;
									Inst = Instr[VIP];
									if not Stk[Inst[2]] then
										VIP = VIP + 1;
									else
										VIP = Inst[3];
									end
								else
									local K;
									local B;
									local A;
									Stk[Inst[2]] = Upvalues[Inst[3]];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									A = Inst[2];
									B = Stk[Inst[3]];
									Stk[A + 1] = B;
									Stk[A] = B[Inst[4]];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]] = Upvalues[Inst[3]];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]] = Inst[3];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									B = Inst[3];
									K = Stk[B];
									for Idx = B + 1, Inst[4] do
										K = K .. Stk[Idx];
									end
									Stk[Inst[2]] = K;
									VIP = VIP + 1;
									Inst = Instr[VIP];
									A = Inst[2];
									Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
									VIP = VIP + 1;
									Inst = Instr[VIP];
									if Stk[Inst[2]] then
										VIP = VIP + 1;
									else
										VIP = Inst[3];
									end
								end
							elseif (Enum <= 49) then
								if (Enum == 48) then
									local FlatIdent_40096 = 0;
									local A;
									while true do
										if (FlatIdent_40096 == 0) then
											A = Inst[2];
											Stk[A](Stk[A + 1]);
											break;
										end
									end
								else
									Stk[Inst[2]] = Stk[Inst[3]][Stk[Inst[4]]];
								end
							elseif (Enum > 50) then
								local Results;
								local Edx;
								local Results, Limit;
								local B;
								local A;
								Stk[Inst[2]] = Env[Inst[3]];
								VIP = VIP + 1;
								Inst = Instr[VIP];
								Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
								VIP = VIP + 1;
								Inst = Instr[VIP];
								for Idx = Inst[2], Inst[3] do
									Stk[Idx] = nil;
								end
								VIP = VIP + 1;
								Inst = Instr[VIP];
								Stk[Inst[2]] = Env[Inst[3]];
								VIP = VIP + 1;
								Inst = Instr[VIP];
								Stk[Inst[2]] = Upvalues[Inst[3]];
								VIP = VIP + 1;
								Inst = Instr[VIP];
								A = Inst[2];
								B = Stk[Inst[3]];
								Stk[A + 1] = B;
								Stk[A] = B[Inst[4]];
								VIP = VIP + 1;
								Inst = Instr[VIP];
								A = Inst[2];
								Results, Limit = _R(Stk[A](Stk[A + 1]));
								Top = (Limit + A) - 1;
								Edx = 0;
								for Idx = A, Top do
									Edx = Edx + 1;
									Stk[Idx] = Results[Edx];
								end
								VIP = VIP + 1;
								Inst = Instr[VIP];
								A = Inst[2];
								Results = {Stk[A](Unpack(Stk, A + 1, Top))};
								Edx = 0;
								for Idx = A, Inst[4] do
									local FlatIdent_622B0 = 0;
									while true do
										if (FlatIdent_622B0 == 0) then
											Edx = Edx + 1;
											Stk[Idx] = Results[Edx];
											break;
										end
									end
								end
								VIP = VIP + 1;
								Inst = Instr[VIP];
								VIP = Inst[3];
							else
								Stk[Inst[2]] = Stk[Inst[3]] + Stk[Inst[4]];
							end
						elseif (Enum <= 77) then
							if (Enum <= 64) then
								if (Enum <= 57) then
									if (Enum <= 54) then
										if (Enum <= 52) then
											local Results;
											local Edx;
											local Results, Limit;
											local B;
											local A;
											Stk[Inst[2]] = Upvalues[Inst[3]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											A = Inst[2];
											B = Stk[Inst[3]];
											Stk[A + 1] = B;
											Stk[A] = B[Inst[4]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											A = Inst[2];
											Results, Limit = _R(Stk[A](Stk[A + 1]));
											Top = (Limit + A) - 1;
											Edx = 0;
											for Idx = A, Top do
												Edx = Edx + 1;
												Stk[Idx] = Results[Edx];
											end
											VIP = VIP + 1;
											Inst = Instr[VIP];
											A = Inst[2];
											Results = {Stk[A](Unpack(Stk, A + 1, Top))};
											Edx = 0;
											for Idx = A, Inst[4] do
												Edx = Edx + 1;
												Stk[Idx] = Results[Edx];
											end
											VIP = VIP + 1;
											Inst = Instr[VIP];
											VIP = Inst[3];
										elseif (Enum > 53) then
											Upvalues[Inst[3]] = Stk[Inst[2]];
										else
											Stk[Inst[2]] = Upvalues[Inst[3]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = not Stk[Inst[3]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Upvalues[Inst[3]] = Stk[Inst[2]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Upvalues[Inst[3]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											if (Stk[Inst[2]] == Inst[4]) then
												VIP = VIP + 1;
											else
												VIP = Inst[3];
											end
										end
									elseif (Enum <= 55) then
										Stk[Inst[2]] = Stk[Inst[3]] / Stk[Inst[4]];
									elseif (Enum > 56) then
										for Idx = Inst[2], Inst[3] do
											Stk[Idx] = nil;
										end
									else
										Stk[Inst[2]] = not Stk[Inst[3]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Env[Inst[3]] = Stk[Inst[2]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Upvalues[Inst[3]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Env[Inst[3]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										VIP = Inst[3];
									end
								elseif (Enum <= 60) then
									if (Enum <= 58) then
										Stk[Inst[2]] = Inst[3] ~= 0;
									elseif (Enum > 59) then
										Stk[Inst[2]] = Inst[3];
									elseif (Stk[Inst[2]] ~= Stk[Inst[4]]) then
										VIP = VIP + 1;
									else
										VIP = Inst[3];
									end
								elseif (Enum <= 62) then
									if (Enum == 61) then
										if (Stk[Inst[2]] < Inst[4]) then
											VIP = VIP + 1;
										else
											VIP = Inst[3];
										end
									else
										local A;
										Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Env[Inst[3]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Env[Inst[3]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Env[Inst[3]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Env[Inst[3]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										A = Inst[2];
										Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Upvalues[Inst[3]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Env[Inst[3]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Inst[3];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										VIP = Inst[3];
									end
								elseif (Enum == 63) then
									local B;
									local A;
									Stk[Inst[2]] = Env[Inst[3]];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]] = Env[Inst[3]];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									A = Inst[2];
									B = Stk[Inst[3]];
									Stk[A + 1] = B;
									Stk[A] = B[Inst[4]];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]] = Inst[3];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									A = Inst[2];
									Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									A = Inst[2];
									B = Stk[Inst[3]];
									Stk[A + 1] = B;
									Stk[A] = B[Inst[4]];
								else
									Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
								end
							elseif (Enum <= 70) then
								if (Enum <= 67) then
									if (Enum <= 65) then
										Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Env[Inst[3]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										if (Stk[Inst[2]] == Stk[Inst[4]]) then
											VIP = VIP + 1;
										else
											VIP = Inst[3];
										end
									elseif (Enum == 66) then
										if Stk[Inst[2]] then
											VIP = VIP + 1;
										else
											VIP = Inst[3];
										end
									else
										local A = Inst[2];
										local C = Inst[4];
										local CB = A + 2;
										local Result = {Stk[A](Stk[A + 1], Stk[CB])};
										for Idx = 1, C do
											Stk[CB + Idx] = Result[Idx];
										end
										local R = Result[1];
										if R then
											local FlatIdent_6066D = 0;
											while true do
												if (FlatIdent_6066D == 0) then
													Stk[CB] = R;
													VIP = Inst[3];
													break;
												end
											end
										else
											VIP = VIP + 1;
										end
									end
								elseif (Enum <= 68) then
									local FlatIdent_43BF7 = 0;
									local B;
									local A;
									while true do
										if (4 == FlatIdent_43BF7) then
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
											VIP = VIP + 1;
											FlatIdent_43BF7 = 5;
										end
										if (1 == FlatIdent_43BF7) then
											Inst = Instr[VIP];
											A = Inst[2];
											B = Stk[Inst[3]];
											Stk[A + 1] = B;
											FlatIdent_43BF7 = 2;
										end
										if (FlatIdent_43BF7 == 3) then
											VIP = VIP + 1;
											Inst = Instr[VIP];
											A = Inst[2];
											Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
											FlatIdent_43BF7 = 4;
										end
										if (5 == FlatIdent_43BF7) then
											Inst = Instr[VIP];
											Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											FlatIdent_43BF7 = 6;
										end
										if (2 == FlatIdent_43BF7) then
											Stk[A] = B[Inst[4]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Inst[3];
											FlatIdent_43BF7 = 3;
										end
										if (FlatIdent_43BF7 == 0) then
											B = nil;
											A = nil;
											Stk[Inst[2]] = Env[Inst[3]];
											VIP = VIP + 1;
											FlatIdent_43BF7 = 1;
										end
										if (FlatIdent_43BF7 == 6) then
											if (Stk[Inst[2]] ~= Stk[Inst[4]]) then
												VIP = VIP + 1;
											else
												VIP = Inst[3];
											end
											break;
										end
									end
								elseif (Enum == 69) then
									local A = Inst[2];
									Stk[A](Unpack(Stk, A + 1, Inst[3]));
								else
									local FlatIdent_22A5C = 0;
									while true do
										if (FlatIdent_22A5C == 2) then
											Stk[Inst[2]] = Env[Inst[3]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											FlatIdent_22A5C = 3;
										end
										if (FlatIdent_22A5C == 1) then
											Stk[Inst[2]] = Upvalues[Inst[3]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											FlatIdent_22A5C = 2;
										end
										if (FlatIdent_22A5C == 4) then
											Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											FlatIdent_22A5C = 5;
										end
										if (FlatIdent_22A5C == 6) then
											VIP = Inst[3];
											break;
										end
										if (3 == FlatIdent_22A5C) then
											Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											FlatIdent_22A5C = 4;
										end
										if (FlatIdent_22A5C == 5) then
											Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											FlatIdent_22A5C = 6;
										end
										if (FlatIdent_22A5C == 0) then
											Upvalues[Inst[3]] = Stk[Inst[2]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											FlatIdent_22A5C = 1;
										end
									end
								end
							elseif (Enum <= 73) then
								if (Enum <= 71) then
									local A;
									Stk[Inst[2]] = Upvalues[Inst[3]];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									A = Inst[2];
									Stk[A] = Stk[A](Stk[A + 1]);
									VIP = VIP + 1;
									Inst = Instr[VIP];
									if Stk[Inst[2]] then
										VIP = VIP + 1;
									else
										VIP = Inst[3];
									end
								elseif (Enum > 72) then
									local FlatIdent_5CC3B = 0;
									while true do
										if (FlatIdent_5CC3B == 1) then
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
											VIP = VIP + 1;
											FlatIdent_5CC3B = 2;
										end
										if (FlatIdent_5CC3B == 0) then
											Stk[Inst[2]] = Upvalues[Inst[3]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Env[Inst[3]];
											FlatIdent_5CC3B = 1;
										end
										if (FlatIdent_5CC3B == 2) then
											Inst = Instr[VIP];
											Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											FlatIdent_5CC3B = 3;
										end
										if (FlatIdent_5CC3B == 3) then
											Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											do
												return;
											end
											break;
										end
									end
								elseif not Stk[Inst[2]] then
									VIP = VIP + 1;
								else
									VIP = Inst[3];
								end
							elseif (Enum <= 75) then
								if (Enum > 74) then
									local A = Inst[2];
									local Results, Limit = _R(Stk[A](Unpack(Stk, A + 1, Inst[3])));
									Top = (Limit + A) - 1;
									local Edx = 0;
									for Idx = A, Top do
										local FlatIdent_679D2 = 0;
										while true do
											if (FlatIdent_679D2 == 0) then
												Edx = Edx + 1;
												Stk[Idx] = Results[Edx];
												break;
											end
										end
									end
								else
									local K;
									local B;
									local A;
									Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]] = Inst[3];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									A = Inst[2];
									Stk[A] = Stk[A](Stk[A + 1]);
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]] = Upvalues[Inst[3]];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]] = Inst[3];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									B = Inst[3];
									K = Stk[B];
									for Idx = B + 1, Inst[4] do
										K = K .. Stk[Idx];
									end
									Stk[Inst[2]] = K;
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]] = Upvalues[Inst[3]];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
								end
							elseif (Enum == 76) then
								local FlatIdent_523B3 = 0;
								local A;
								while true do
									if (FlatIdent_523B3 == 0) then
										A = Inst[2];
										Stk[A] = Stk[A](Unpack(Stk, A + 1, Top));
										break;
									end
								end
							elseif (Inst[2] == Stk[Inst[4]]) then
								VIP = VIP + 1;
							else
								VIP = Inst[3];
							end
						elseif (Enum <= 90) then
							if (Enum <= 83) then
								if (Enum <= 80) then
									if (Enum <= 78) then
										local FlatIdent_74B46 = 0;
										local A;
										while true do
											if (FlatIdent_74B46 == 1) then
												Inst = Instr[VIP];
												Stk[Inst[2]] = Env[Inst[3]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
												VIP = VIP + 1;
												FlatIdent_74B46 = 2;
											end
											if (FlatIdent_74B46 == 2) then
												Inst = Instr[VIP];
												Stk[Inst[2]] = Inst[3];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												A = Inst[2];
												Stk[A] = Stk[A](Stk[A + 1]);
												FlatIdent_74B46 = 3;
											end
											if (FlatIdent_74B46 == 5) then
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]][Inst[3]] = Inst[4];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Inst[3];
												break;
											end
											if (FlatIdent_74B46 == 0) then
												A = nil;
												Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
												VIP = VIP + 1;
												FlatIdent_74B46 = 1;
											end
											if (FlatIdent_74B46 == 4) then
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
												FlatIdent_74B46 = 5;
											end
											if (FlatIdent_74B46 == 3) then
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]][Inst[3]] = Stk[Inst[4]];
												VIP = VIP + 1;
												Inst = Instr[VIP];
												Stk[Inst[2]] = Upvalues[Inst[3]];
												FlatIdent_74B46 = 4;
											end
										end
									elseif (Enum > 79) then
										local A;
										Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Inst[3];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										A = Inst[2];
										Stk[A](Stk[A + 1]);
										VIP = VIP + 1;
										Inst = Instr[VIP];
										Stk[Inst[2]] = Upvalues[Inst[3]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										if Stk[Inst[2]] then
											VIP = VIP + 1;
										else
											VIP = Inst[3];
										end
									else
										Stk[Inst[2]]();
									end
								elseif (Enum <= 81) then
									local NewProto = Proto[Inst[3]];
									local NewUvals;
									local Indexes = {};
									NewUvals = Setmetatable({}, {__index=function(_, Key)
										local Val = Indexes[Key];
										return Val[1][Val[2]];
									end,__newindex=function(_, Key, Value)
										local FlatIdent_340E5 = 0;
										local Val;
										while true do
											if (FlatIdent_340E5 == 0) then
												Val = Indexes[Key];
												Val[1][Val[2]] = Value;
												break;
											end
										end
									end});
									for Idx = 1, Inst[4] do
										VIP = VIP + 1;
										local Mvm = Instr[VIP];
										if (Mvm[1] == 40) then
											Indexes[Idx - 1] = {Stk,Mvm[3]};
										else
											Indexes[Idx - 1] = {Upvalues,Mvm[3]};
										end
										Lupvals[#Lupvals + 1] = Indexes;
									end
									Stk[Inst[2]] = Wrap(NewProto, NewUvals, Env);
								elseif (Enum == 82) then
									local A = Inst[2];
									local Results = {Stk[A](Unpack(Stk, A + 1, Top))};
									local Edx = 0;
									for Idx = A, Inst[4] do
										local FlatIdent_4BE81 = 0;
										while true do
											if (FlatIdent_4BE81 == 0) then
												Edx = Edx + 1;
												Stk[Idx] = Results[Edx];
												break;
											end
										end
									end
								else
									local FlatIdent_9525B = 0;
									local Edx;
									local Results;
									local B;
									local A;
									while true do
										if (FlatIdent_9525B == 7) then
											Edx = 0;
											for Idx = A, Inst[4] do
												Edx = Edx + 1;
												Stk[Idx] = Results[Edx];
											end
											VIP = VIP + 1;
											Inst = Instr[VIP];
											FlatIdent_9525B = 8;
										end
										if (8 == FlatIdent_9525B) then
											VIP = Inst[3];
											break;
										end
										if (FlatIdent_9525B == 5) then
											A = Inst[2];
											B = Stk[Inst[3]];
											Stk[A + 1] = B;
											Stk[A] = B[Inst[4]];
											FlatIdent_9525B = 6;
										end
										if (3 == FlatIdent_9525B) then
											Inst = Instr[VIP];
											Stk[Inst[2]] = Inst[3];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											FlatIdent_9525B = 4;
										end
										if (FlatIdent_9525B == 0) then
											Edx = nil;
											Results = nil;
											B = nil;
											A = nil;
											FlatIdent_9525B = 1;
										end
										if (FlatIdent_9525B == 2) then
											B = Stk[Inst[3]];
											Stk[A + 1] = B;
											Stk[A] = B[Inst[4]];
											VIP = VIP + 1;
											FlatIdent_9525B = 3;
										end
										if (4 == FlatIdent_9525B) then
											A = Inst[2];
											Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
											VIP = VIP + 1;
											Inst = Instr[VIP];
											FlatIdent_9525B = 5;
										end
										if (FlatIdent_9525B == 6) then
											VIP = VIP + 1;
											Inst = Instr[VIP];
											A = Inst[2];
											Results = {Stk[A](Stk[A + 1])};
											FlatIdent_9525B = 7;
										end
										if (FlatIdent_9525B == 1) then
											Stk[Inst[2]] = Env[Inst[3]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											A = Inst[2];
											FlatIdent_9525B = 2;
										end
									end
								end
							elseif (Enum <= 86) then
								if (Enum <= 84) then
									Stk[Inst[2]] = Env[Inst[3]];
								elseif (Enum > 85) then
									local FlatIdent_8325F = 0;
									local A;
									while true do
										if (FlatIdent_8325F == 5) then
											Stk[A] = Stk[A](Stk[A + 1]);
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]][Inst[3]] = Inst[4];
											FlatIdent_8325F = 6;
										end
										if (FlatIdent_8325F == 3) then
											Inst = Instr[VIP];
											Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											FlatIdent_8325F = 4;
										end
										if (FlatIdent_8325F == 4) then
											Stk[Inst[2]] = Inst[3];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											A = Inst[2];
											FlatIdent_8325F = 5;
										end
										if (7 == FlatIdent_8325F) then
											Inst = Instr[VIP];
											Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
											break;
										end
										if (FlatIdent_8325F == 2) then
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Env[Inst[3]];
											VIP = VIP + 1;
											FlatIdent_8325F = 3;
										end
										if (0 == FlatIdent_8325F) then
											A = nil;
											Stk[Inst[2]][Inst[3]] = Inst[4];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											FlatIdent_8325F = 1;
										end
										if (FlatIdent_8325F == 1) then
											Stk[Inst[2]] = Env[Inst[3]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]][Inst[3]] = Inst[4];
											FlatIdent_8325F = 2;
										end
										if (6 == FlatIdent_8325F) then
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Env[Inst[3]];
											VIP = VIP + 1;
											FlatIdent_8325F = 7;
										end
									end
								else
									Stk[Inst[2]] = Upvalues[Inst[3]];
								end
							elseif (Enum <= 88) then
								if (Enum == 87) then
									Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]] = Upvalues[Inst[3]];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									if (Stk[Inst[2]] ~= Stk[Inst[4]]) then
										VIP = VIP + 1;
									else
										VIP = Inst[3];
									end
								else
									local FlatIdent_FC26 = 0;
									local Edx;
									local Results;
									local Limit;
									local B;
									local A;
									while true do
										if (4 == FlatIdent_FC26) then
											Stk[Inst[2]] = Inst[3];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											A = Inst[2];
											Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
											VIP = VIP + 1;
											Inst = Instr[VIP];
											A = Inst[2];
											B = Stk[Inst[3]];
											Stk[A + 1] = B;
											FlatIdent_FC26 = 5;
										end
										if (FlatIdent_FC26 == 26) then
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Inst[3] ~= 0;
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Inst[3] ~= 0;
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Inst[3];
											VIP = VIP + 1;
											FlatIdent_FC26 = 27;
										end
										if (FlatIdent_FC26 == 9) then
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Inst[3] ~= 0;
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Env[Inst[3]] = Stk[Inst[2]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Inst[3] ~= 0;
											VIP = VIP + 1;
											FlatIdent_FC26 = 10;
										end
										if (2 == FlatIdent_FC26) then
											Results, Limit = _R(Stk[A](Unpack(Stk, A + 1, Inst[3])));
											Top = (Limit + A) - 1;
											Edx = 0;
											for Idx = A, Top do
												Edx = Edx + 1;
												Stk[Idx] = Results[Edx];
											end
											VIP = VIP + 1;
											Inst = Instr[VIP];
											A = Inst[2];
											Stk[A] = Stk[A](Unpack(Stk, A + 1, Top));
											VIP = VIP + 1;
											Inst = Instr[VIP];
											FlatIdent_FC26 = 3;
										end
										if (FlatIdent_FC26 == 15) then
											A = Inst[2];
											B = Stk[Inst[3]];
											Stk[A + 1] = B;
											Stk[A] = B[Inst[4]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Inst[3];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											A = Inst[2];
											FlatIdent_FC26 = 16;
										end
										if (17 == FlatIdent_FC26) then
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Inst[3];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											A = Inst[2];
											Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Env[Inst[3]];
											FlatIdent_FC26 = 18;
										end
										if (FlatIdent_FC26 == 1) then
											A = Inst[2];
											B = Stk[Inst[3]];
											Stk[A + 1] = B;
											Stk[A] = B[Inst[4]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Inst[3];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											A = Inst[2];
											FlatIdent_FC26 = 2;
										end
										if (FlatIdent_FC26 == 24) then
											Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
											VIP = VIP + 1;
											Inst = Instr[VIP];
											A = Inst[2];
											B = Stk[Inst[3]];
											Stk[A + 1] = B;
											Stk[A] = B[Inst[4]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											A = Inst[2];
											FlatIdent_FC26 = 25;
										end
										if (FlatIdent_FC26 == 21) then
											Inst = Instr[VIP];
											Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											A = Inst[2];
											B = Stk[Inst[3]];
											Stk[A + 1] = B;
											FlatIdent_FC26 = 22;
										end
										if (8 == FlatIdent_FC26) then
											VIP = VIP + 1;
											Inst = Instr[VIP];
											A = Inst[2];
											Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Inst[3];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Env[Inst[3]] = Stk[Inst[2]];
											FlatIdent_FC26 = 9;
										end
										if (FlatIdent_FC26 == 28) then
											Stk[Inst[2]] = Inst[3];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Inst[3];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											A = Inst[2];
											Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
											VIP = VIP + 1;
											Inst = Instr[VIP];
											FlatIdent_FC26 = 29;
										end
										if (FlatIdent_FC26 == 12) then
											B = Stk[Inst[3]];
											Stk[A + 1] = B;
											Stk[A] = B[Inst[4]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Inst[3];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											A = Inst[2];
											Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
											FlatIdent_FC26 = 13;
										end
										if (FlatIdent_FC26 == 7) then
											Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
											VIP = VIP + 1;
											Inst = Instr[VIP];
											A = Inst[2];
											B = Stk[Inst[3]];
											Stk[A + 1] = B;
											Stk[A] = B[Inst[4]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Inst[3];
											FlatIdent_FC26 = 8;
										end
										if (22 == FlatIdent_FC26) then
											Stk[A] = B[Inst[4]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Inst[3];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											A = Inst[2];
											Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
											VIP = VIP + 1;
											Inst = Instr[VIP];
											FlatIdent_FC26 = 23;
										end
										if (FlatIdent_FC26 == 23) then
											A = Inst[2];
											B = Stk[Inst[3]];
											Stk[A + 1] = B;
											Stk[A] = B[Inst[4]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Inst[3];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											A = Inst[2];
											FlatIdent_FC26 = 24;
										end
										if (FlatIdent_FC26 == 13) then
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Inst[3] ~= 0;
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Env[Inst[3]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
											VIP = VIP + 1;
											FlatIdent_FC26 = 14;
										end
										if (FlatIdent_FC26 == 10) then
											Inst = Instr[VIP];
											Env[Inst[3]] = Stk[Inst[2]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Inst[3] ~= 0;
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Env[Inst[3]] = Stk[Inst[2]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											FlatIdent_FC26 = 11;
										end
										if (FlatIdent_FC26 == 25) then
											Stk[A] = Stk[A](Stk[A + 1]);
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Inst[3] ~= 0;
											FlatIdent_FC26 = 26;
										end
										if (FlatIdent_FC26 == 30) then
											VIP = VIP + 1;
											Inst = Instr[VIP];
											A = Inst[2];
											Stk[A] = Stk[A](Stk[A + 1]);
											break;
										end
										if (FlatIdent_FC26 == 27) then
											Inst = Instr[VIP];
											Stk[Inst[2]] = Env[Inst[3]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Inst[3];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											FlatIdent_FC26 = 28;
										end
										if (FlatIdent_FC26 == 16) then
											Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Env[Inst[3]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											A = Inst[2];
											B = Stk[Inst[3]];
											Stk[A + 1] = B;
											Stk[A] = B[Inst[4]];
											FlatIdent_FC26 = 17;
										end
										if (FlatIdent_FC26 == 6) then
											A = Inst[2];
											B = Stk[Inst[3]];
											Stk[A + 1] = B;
											Stk[A] = B[Inst[4]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Inst[3];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											A = Inst[2];
											FlatIdent_FC26 = 7;
										end
										if (FlatIdent_FC26 == 14) then
											Inst = Instr[VIP];
											Stk[Inst[2]] = Env[Inst[3]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Env[Inst[3]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											FlatIdent_FC26 = 15;
										end
										if (FlatIdent_FC26 == 3) then
											A = Inst[2];
											Stk[A] = Stk[A]();
											VIP = VIP + 1;
											Inst = Instr[VIP];
											A = Inst[2];
											B = Stk[Inst[3]];
											Stk[A + 1] = B;
											Stk[A] = B[Inst[4]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											FlatIdent_FC26 = 4;
										end
										if (5 == FlatIdent_FC26) then
											Stk[A] = B[Inst[4]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Inst[3];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											A = Inst[2];
											Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
											VIP = VIP + 1;
											Inst = Instr[VIP];
											FlatIdent_FC26 = 6;
										end
										if (FlatIdent_FC26 == 0) then
											Edx = nil;
											Results, Limit = nil;
											B = nil;
											A = nil;
											Stk[Inst[2]] = Env[Inst[3]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Env[Inst[3]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											FlatIdent_FC26 = 1;
										end
										if (29 == FlatIdent_FC26) then
											Stk[Inst[2]] = Env[Inst[3]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											A = Inst[2];
											B = Stk[Inst[3]];
											Stk[A + 1] = B;
											Stk[A] = B[Inst[4]];
											FlatIdent_FC26 = 30;
										end
										if (FlatIdent_FC26 == 19) then
											Inst = Instr[VIP];
											A = Inst[2];
											Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Env[Inst[3]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											A = Inst[2];
											B = Stk[Inst[3]];
											FlatIdent_FC26 = 20;
										end
										if (FlatIdent_FC26 == 20) then
											Stk[A + 1] = B;
											Stk[A] = B[Inst[4]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Inst[3];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											A = Inst[2];
											Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
											VIP = VIP + 1;
											FlatIdent_FC26 = 21;
										end
										if (18 == FlatIdent_FC26) then
											VIP = VIP + 1;
											Inst = Instr[VIP];
											A = Inst[2];
											B = Stk[Inst[3]];
											Stk[A + 1] = B;
											Stk[A] = B[Inst[4]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Inst[3];
											VIP = VIP + 1;
											FlatIdent_FC26 = 19;
										end
										if (11 == FlatIdent_FC26) then
											Stk[Inst[2]] = Env[Inst[3]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]][Inst[3]] = Inst[4];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Env[Inst[3]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											A = Inst[2];
											FlatIdent_FC26 = 12;
										end
									end
								end
							elseif (Enum == 89) then
								local B;
								local A;
								A = Inst[2];
								B = Stk[Inst[3]];
								Stk[A + 1] = B;
								Stk[A] = B[Inst[4]];
								VIP = VIP + 1;
								Inst = Instr[VIP];
								A = Inst[2];
								Stk[A](Stk[A + 1]);
								VIP = VIP + 1;
								Inst = Instr[VIP];
								Stk[Inst[2]] = Upvalues[Inst[3]];
								VIP = VIP + 1;
								Inst = Instr[VIP];
								A = Inst[2];
								B = Stk[Inst[3]];
								Stk[A + 1] = B;
								Stk[A] = B[Inst[4]];
								VIP = VIP + 1;
								Inst = Instr[VIP];
								A = Inst[2];
								Stk[A](Stk[A + 1]);
								VIP = VIP + 1;
								Inst = Instr[VIP];
								VIP = Inst[3];
							else
								Stk[Inst[2]] = Stk[Inst[3]] - Stk[Inst[4]];
							end
						elseif (Enum <= 96) then
							if (Enum <= 93) then
								if (Enum <= 91) then
									local Results;
									local Edx;
									local Results, Limit;
									local B;
									local A;
									Stk[Inst[2]] = Env[Inst[3]];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									A = Inst[2];
									B = Stk[Inst[3]];
									Stk[A + 1] = B;
									Stk[A] = B[Inst[4]];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									A = Inst[2];
									Results, Limit = _R(Stk[A](Stk[A + 1]));
									Top = (Limit + A) - 1;
									Edx = 0;
									for Idx = A, Top do
										Edx = Edx + 1;
										Stk[Idx] = Results[Edx];
									end
									VIP = VIP + 1;
									Inst = Instr[VIP];
									A = Inst[2];
									Results = {Stk[A](Unpack(Stk, A + 1, Top))};
									Edx = 0;
									for Idx = A, Inst[4] do
										local FlatIdent_81F9 = 0;
										while true do
											if (FlatIdent_81F9 == 0) then
												Edx = Edx + 1;
												Stk[Idx] = Results[Edx];
												break;
											end
										end
									end
									VIP = VIP + 1;
									Inst = Instr[VIP];
									VIP = Inst[3];
								elseif (Enum > 92) then
									local FlatIdent_2E7F5 = 0;
									local B;
									local A;
									while true do
										if (FlatIdent_2E7F5 == 4) then
											VIP = VIP + 1;
											Inst = Instr[VIP];
											A = Inst[2];
											FlatIdent_2E7F5 = 5;
										end
										if (FlatIdent_2E7F5 == 5) then
											Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
											VIP = VIP + 1;
											Inst = Instr[VIP];
											FlatIdent_2E7F5 = 6;
										end
										if (FlatIdent_2E7F5 == 1) then
											VIP = VIP + 1;
											Inst = Instr[VIP];
											A = Inst[2];
											FlatIdent_2E7F5 = 2;
										end
										if (FlatIdent_2E7F5 == 2) then
											B = Stk[Inst[3]];
											Stk[A + 1] = B;
											Stk[A] = B[Inst[4]];
											FlatIdent_2E7F5 = 3;
										end
										if (FlatIdent_2E7F5 == 0) then
											B = nil;
											A = nil;
											Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
											FlatIdent_2E7F5 = 1;
										end
										if (3 == FlatIdent_2E7F5) then
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Inst[3];
											FlatIdent_2E7F5 = 4;
										end
										if (FlatIdent_2E7F5 == 6) then
											if Stk[Inst[2]] then
												VIP = VIP + 1;
											else
												VIP = Inst[3];
											end
											break;
										end
									end
								else
									local FlatIdent_4EC26 = 0;
									local Edx;
									local Results;
									local B;
									local A;
									while true do
										if (FlatIdent_4EC26 == 4) then
											Inst = Instr[VIP];
											A = Inst[2];
											Results = {Stk[A](Unpack(Stk, A + 1, Inst[3]))};
											Edx = 0;
											for Idx = A, Inst[4] do
												Edx = Edx + 1;
												Stk[Idx] = Results[Edx];
											end
											VIP = VIP + 1;
											FlatIdent_4EC26 = 5;
										end
										if (FlatIdent_4EC26 == 5) then
											Inst = Instr[VIP];
											Stk[Inst[2]] = Stk[Inst[3]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Stk[Inst[3]];
											VIP = VIP + 1;
											FlatIdent_4EC26 = 6;
										end
										if (FlatIdent_4EC26 == 6) then
											Inst = Instr[VIP];
											Stk[Inst[2]] = Inst[3];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											VIP = Inst[3];
											break;
										end
										if (FlatIdent_4EC26 == 1) then
											Inst = Instr[VIP];
											A = Inst[2];
											B = Stk[Inst[3]];
											Stk[A + 1] = B;
											Stk[A] = B[Inst[4]];
											VIP = VIP + 1;
											FlatIdent_4EC26 = 2;
										end
										if (FlatIdent_4EC26 == 0) then
											Edx = nil;
											Results = nil;
											B = nil;
											A = nil;
											Stk[Inst[2]] = Upvalues[Inst[3]];
											VIP = VIP + 1;
											FlatIdent_4EC26 = 1;
										end
										if (FlatIdent_4EC26 == 3) then
											Inst = Instr[VIP];
											Stk[Inst[2]] = Stk[Inst[3]][Stk[Inst[4]]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
											VIP = VIP + 1;
											FlatIdent_4EC26 = 4;
										end
										if (FlatIdent_4EC26 == 2) then
											Inst = Instr[VIP];
											Stk[Inst[2]] = Env[Inst[3]];
											VIP = VIP + 1;
											Inst = Instr[VIP];
											Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
											VIP = VIP + 1;
											FlatIdent_4EC26 = 3;
										end
									end
								end
							elseif (Enum <= 94) then
								local B;
								local A;
								Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
								VIP = VIP + 1;
								Inst = Instr[VIP];
								A = Inst[2];
								B = Stk[Inst[3]];
								Stk[A + 1] = B;
								Stk[A] = B[Inst[4]];
								VIP = VIP + 1;
								Inst = Instr[VIP];
								Stk[Inst[2]] = Inst[3];
								VIP = VIP + 1;
								Inst = Instr[VIP];
								A = Inst[2];
								Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
								VIP = VIP + 1;
								Inst = Instr[VIP];
								if Stk[Inst[2]] then
									VIP = VIP + 1;
								else
									VIP = Inst[3];
								end
							elseif (Enum == 95) then
								Stk[Inst[2]][Inst[3]] = Inst[4];
							elseif (Stk[Inst[2]] ~= Inst[4]) then
								VIP = VIP + 1;
							else
								VIP = Inst[3];
							end
						elseif (Enum <= 99) then
							if (Enum <= 97) then
								if (Stk[Inst[2]] == Inst[4]) then
									VIP = VIP + 1;
								else
									VIP = Inst[3];
								end
							elseif (Enum == 98) then
								local A;
								Stk[Inst[2]] = Env[Inst[3]];
								VIP = VIP + 1;
								Inst = Instr[VIP];
								Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
								VIP = VIP + 1;
								Inst = Instr[VIP];
								Stk[Inst[2]] = Stk[Inst[3]] * Stk[Inst[4]];
								VIP = VIP + 1;
								Inst = Instr[VIP];
								Stk[Inst[2]] = Stk[Inst[3]] + Inst[4];
								VIP = VIP + 1;
								Inst = Instr[VIP];
								A = Inst[2];
								Stk[A] = Stk[A](Stk[A + 1]);
								VIP = VIP + 1;
								Inst = Instr[VIP];
								Stk[Inst[2]] = Stk[Inst[3]] / Stk[Inst[4]];
								VIP = VIP + 1;
								Inst = Instr[VIP];
								do
									return Stk[Inst[2]];
								end
								VIP = VIP + 1;
								Inst = Instr[VIP];
								VIP = Inst[3];
							else
								Stk[Inst[2]] = Stk[Inst[3]] * Stk[Inst[4]];
							end
						elseif (Enum <= 101) then
							if (Enum > 100) then
								local FlatIdent_53895 = 0;
								local B;
								local A;
								while true do
									if (FlatIdent_53895 == 0) then
										B = nil;
										A = nil;
										A = Inst[2];
										FlatIdent_53895 = 1;
									end
									if (2 == FlatIdent_53895) then
										VIP = VIP + 1;
										Inst = Instr[VIP];
										A = Inst[2];
										FlatIdent_53895 = 3;
									end
									if (FlatIdent_53895 == 6) then
										Stk[A] = B[Inst[4]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										FlatIdent_53895 = 7;
									end
									if (FlatIdent_53895 == 7) then
										A = Inst[2];
										Stk[A](Stk[A + 1]);
										VIP = VIP + 1;
										FlatIdent_53895 = 8;
									end
									if (FlatIdent_53895 == 3) then
										Stk[A](Stk[A + 1]);
										VIP = VIP + 1;
										Inst = Instr[VIP];
										FlatIdent_53895 = 4;
									end
									if (FlatIdent_53895 == 1) then
										B = Stk[Inst[3]];
										Stk[A + 1] = B;
										Stk[A] = B[Inst[4]];
										FlatIdent_53895 = 2;
									end
									if (5 == FlatIdent_53895) then
										A = Inst[2];
										B = Stk[Inst[3]];
										Stk[A + 1] = B;
										FlatIdent_53895 = 6;
									end
									if (FlatIdent_53895 == 4) then
										Stk[Inst[2]] = Upvalues[Inst[3]];
										VIP = VIP + 1;
										Inst = Instr[VIP];
										FlatIdent_53895 = 5;
									end
									if (FlatIdent_53895 == 9) then
										Inst = Instr[VIP];
										VIP = Inst[3];
										break;
									end
									if (FlatIdent_53895 == 8) then
										Inst = Instr[VIP];
										Stk[Inst[2]] = Inst[3];
										VIP = VIP + 1;
										FlatIdent_53895 = 9;
									end
								end
							else
								local A = Inst[2];
								local Results, Limit = _R(Stk[A](Stk[A + 1]));
								Top = (Limit + A) - 1;
								local Edx = 0;
								for Idx = A, Top do
									local FlatIdent_580B8 = 0;
									while true do
										if (FlatIdent_580B8 == 0) then
											Edx = Edx + 1;
											Stk[Idx] = Results[Edx];
											break;
										end
									end
								end
							end
						elseif (Enum > 102) then
							local FlatIdent_3BEFE = 0;
							local A;
							while true do
								if (0 == FlatIdent_3BEFE) then
									A = Inst[2];
									Stk[A] = Stk[A](Stk[A + 1]);
									break;
								end
							end
						else
							local FlatIdent_5AC6 = 0;
							local B;
							local A;
							while true do
								if (FlatIdent_5AC6 == 4) then
									Inst = Instr[VIP];
									A = Inst[2];
									Stk[A] = Stk[A](Unpack(Stk, A + 1, Inst[3]));
									VIP = VIP + 1;
									FlatIdent_5AC6 = 5;
								end
								if (FlatIdent_5AC6 == 5) then
									Inst = Instr[VIP];
									if Stk[Inst[2]] then
										VIP = VIP + 1;
									else
										VIP = Inst[3];
									end
									break;
								end
								if (FlatIdent_5AC6 == 0) then
									B = nil;
									A = nil;
									Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
									VIP = VIP + 1;
									FlatIdent_5AC6 = 1;
								end
								if (FlatIdent_5AC6 == 2) then
									A = Inst[2];
									B = Stk[Inst[3]];
									Stk[A + 1] = B;
									Stk[A] = B[Inst[4]];
									FlatIdent_5AC6 = 3;
								end
								if (FlatIdent_5AC6 == 1) then
									Inst = Instr[VIP];
									Stk[Inst[2]] = Stk[Inst[3]][Inst[4]];
									VIP = VIP + 1;
									Inst = Instr[VIP];
									FlatIdent_5AC6 = 2;
								end
								if (FlatIdent_5AC6 == 3) then
									VIP = VIP + 1;
									Inst = Instr[VIP];
									Stk[Inst[2]] = Inst[3];
									VIP = VIP + 1;
									FlatIdent_5AC6 = 4;
								end
							end
						end
						VIP = VIP + 1;
						break;
					end
				end
			end
		end;
	end
	return Wrap(Deserialize(), {}, vmenv)(...);
end
return VMCall("LOL!5C3O00030A3O006C6F6164737472696E6703043O0067616D6503073O00482O7470476574034A3O00682O7470733A2O2F7261772E67697468756275736572636F6E74656E742E636F6D2F626C2O6F6462612O6C2F2D6261636B2D7570732D666F722D6C6962732F6D61696E2F77697A61726403093O004E657757696E646F77030F3O006E692O676572626561746572363738030A3O004E657753656374696F6E2O033O0041544B03053O004D6973637303083O0073652O74696E6773030C3O007472616E73706172656E637902AE47E17A14AEEF3F2O033O004A2O4B2O033O0065737003063O0061696D626F7403023O005F4703083O0044697361626C65642O01030A3O0047657453657276696365030A3O0052756E5365727669636503073O00436F726547756903073O00506C617965727303093O00576F726B737061636503103O0055736572496E70757453657276696365030B3O004C6F63616C506C6179657203093O00436861726163746572030E3O0046696E6446697273744368696C6403103O0048756D616E6F6964522O6F745061727403083O0048756D616E6F696403083O004765744D6F757365030D3O0043752O72656E7443616D65726103093O005465616D436F6C6F7202560E2DB29DEFC73F03073O00566563746F72332O033O006E6577028O00029A5O99B93F03043O0070696E6703043O006D61746803053O00726F756E64030E3O004765744E6574776F726B50696E67025O00408F40025O00C05140026O00544002A6F1DC3AA5D4C13F025O00804E40025O0080514002D11805937D9BC03F026O004E4002F496059FE206C03F2O033O002O736B03093O005465616D436865636B010003073O0041696D5061727403043O0048656164030B3O0053656E7369746976697479030B3O00436972636C655369646573026O005040030B3O00436972636C65436F6C6F7203063O00436F6C6F723303073O0066726F6D524742025O00E06F40025O0040604003123O00436972636C655472616E73706172656E6379030C3O00436972636C65526164697573026O006940030C3O00436972636C6546692O6C6564030F3O00436972636C65546869636B6E652O73026O00F03F03073O0044726177696E6703063O00436972636C6503073O0056697369626C6503053O00436F6C6F7203093O00546869636B6E652O7303083O004E756D5369646573026O003E4003063O0052616469757303043O004D6F766503073O00436F2O6E656374030D3O0043726561746554657874626F7803063O00486974626F78030C3O00437265617465546F2O676C6503083O0053686F772065737003063O0041696D626F74030A3O00496E707574426567616E030A3O00496E707574456E646564030D3O00496E76697320426C7565426F78030D3O0028436972636C65292053697A65030E3O0028436972636C652920436F6C6F7203073O00676574522O6F742O033O0045535003113O0046696E644E656172657374506C6179657200E43O0012583O00013O00122O000100023O00202O00010001000300122O000300046O000100039O0000026O0001000200202O00013O000500122O000300066O00010003000200202O00020001000700122O000400086O00020004000200202O00030001000700122O000500096O00030005000200202O00040001000700122O0006000A6O00040006000200122O0005000C3O00122O0005000B6O000500013O00122O0005000D6O00055O00122O0005000E6O00055O00122O0005000F3O00122O000500103O00302O00050011001200122O000500023O00202O00050005001300122O000700146O0005000700024O00065O00122O000700023O00202O00070007001500122O000800023O00202O00080008001600122O000900023O00202O00090009001300122O000B00176O0009000B000200122O000A00023O00202O000A000A001300122O000C00146O000A000C000200122O000B00023O00202O000B000B001300122O000D00186O000B000D000200122O000C00023O00202O000C000C001300122O000E00166O000C000E000200202O000D000C001900202O000E000D001A00202O000F000E001B00122O0011001C6O000F0011000200202O0010000E001B00122O0012001D6O00100012000200202O0011000D001E4O00110002000200202O00120009001F00202O0013000D00204O00148O00158O00165O00122O001700213O00122O001800223O00202O00180018002300122O001900243O00122O001A00253O00122O001B00246O0018001B000200122O001900273O00202O00190019002800202O001A000D00294O001A00020002002023001A001A002A4O00190002000200122O001900263O00122O001900263O000E2O002B005B0001001900042D3O005B0001001254001900263O00263D0019005B0001002C00042D3O005B000100123C0017002D3O00042D3O00670001001254001900263O000E0A002E00630001001900042D3O00630001001254001900263O00263D001900630001002F00042D3O0063000100123C001700303O00042D3O00670001001254001900263O00263D001900670001003100042D3O0067000100123C001700324O003A00195O001213001900333O00122O001900103O00302O00190034003500122O001900103O00302O00190036003700122O001900103O00302O00190038002400122O001900103O00302O00190039003A00122O001900103O001254001A003C3O00201A001A001A003D00122O001B003E3O00122O001C00243O00122O001D003F6O001A001D000200102O0019003B001A00122O001900103O00302O00190040002400122O001900103O00302O001900410042001254001900103O00305600190043003500122O001900103O00302O00190044004500122O001900463O00202O00190019002300122O001A00476O00190002000200302O00190048003500122O001A00103O00202O001A001A003B00102O00190049001A00120F001A00103O00202O001A001A004400102O0019004A001A00302O0019004B004C00122O001A00103O00202O001A001A004100102O0019004D001A00202O001A0011004E00202O001A001A004F000651001C3O000100022O00283O00194O00283O00114O0045001A001C0001000651001A0001000100012O00283O000B3O000651001B0002000100042O00283O00144O00283O00154O00283O00164O00283O000B3O00201D001C0002005000123C001E00513O000210001F00034O0045001C001F000100201D001C0002005200123C001E00533O000651001F0004000100022O00283O00064O00283O00074O0045001C001F000100201D001C0002005200123C001E00543O000651001F0005000100032O00283O00154O00283O00164O00283O00144O0045001C001F0001002040001C000B005500201D001C001C004F000651001E0006000100072O00283O00144O00283O00154O00283O00164O00283O00174O00283O00184O00283O00124O00283O001A4O0045001C001E0001002040001C000B005600201D001C001C004F000651001E0007000100012O00283O001B4O0045001C001E000100201D001C0003005200123C001E00573O000210001F00084O0045001C001F000100201D001C0003005200123C001E00473O000651001F0009000100012O00283O00194O0045001C001F000100201D001C0004005000123C001E00583O000651001F000A000100012O00283O00194O0045001C001F000100201D001C0004005000123C001E00593O000651001F000B000100012O00283O00194O0045001C001F0001000210001C000C3O001201001C005A3O000210001C000D3O001201001C00283O000651001C000E000100042O00283O00074O00283O000C4O00283O00064O00283O000A3O001201001C005B3O000651001C000F000100052O00283O000C4O00283O000D4O00283O00114O00283O00194O00283O00123O001201001C005C4O00208O002A3O00013O00103O00053O0003083O00506F736974696F6E03073O00566563746F72332O033O006E657703013O005803013O0059000A4O00047O00122O000100023O00202O0001000100034O000200013O00202O0002000200044O000300013O00202O0003000300054O00010003000200104O000100016O00017O00033O00030D3O004D6F7573654265686176696F7203043O00456E756D030A3O004C6F636B43656E74657200064O00497O00122O000100023O00202O00010001000100202O00010001000300104O000100016O00017O00053O00028O00026O00F03F030D3O004D6F7573654265686176696F7203043O00456E756D03073O0044656661756C7400143O00123C3O00013O000E4D0001000800013O00042D3O000800012O003A00016O003600016O003A00016O0036000100013O00123C3O00023O0026613O00010001000200042D3O000100012O003A00016O0046000100026O000100033O00122O000200043O00202O00020002000300202O00020002000500102O00010003000200044O0013000100042D3O000100012O002A3O00017O00073O0003023O005F4703083O004865616453697A6503043O0067616D65030A3O0047657453657276696365030A3O0052756E53657276696365030D3O0052656E6465725374652O70656403073O00636F2O6E656374010B3O00123F000100013O00102O000100023O00122O000100033O00202O00010001000400122O000300056O00010003000200202O00010001000600202O00010001000700021000036O00450001000300012O002A3O00013O00013O000A3O0003023O005F4703083O0044697361626C656403043O006E65787403043O0067616D65030A3O004765745365727669636503073O00506C6179657273030A3O00476574506C617965727303043O004E616D65030B3O004C6F63616C506C6179657203053O007063612O6C001D3O0012543O00013O0020405O00020006423O001C00013O00042D3O001C00010012543O00033O001253000100043O00202O00010001000500122O000300066O00010003000200202O0001000100074O00010002000200044O001A0001002040000500040008001244000600043O00202O00060006000500122O000800066O00060008000200202O00060006000900202O00060006000800062O000500190001000600042D3O001900010012540005000A3O00065100063O000100012O00283O00044O00300005000200012O002000035O0006433O000C0001000200042D3O000C00012O002A3O00013O00013O00123O00028O00027O004003093O0043686172616374657203103O0048756D616E6F6964522O6F7450617274030A3O0043616E436F2O6C6964650100026O00F03F030A3O00427269636B436F6C6F722O033O006E6577030B3O005265612O6C7920626C756503083O004D6174657269616C03043O004E656F6E03043O0053697A6503073O00566563746F723303023O005F4703083O004865616453697A65030C3O005472616E73706172656E6379030C3O007472616E73706172656E6379002E3O00123C3O00013O0026613O00080001000200042D3O000800012O005500015O00204000010001000300204000010001000400305F00010005000600042D3O002D0001000E4D0007001700013O00042D3O001700012O005500015O00204E00010001000300202O00010001000400122O000200083O00202O00020002000900122O0003000A6O00020002000200102O0001000800024O00015O00202O00010001000300202O00010001000400302O0001000B000C00124O00023O0026613O00010001000100042D3O000100012O005500015O00203E00010001000300202O00010001000400122O0002000E3O00202O00020002000900122O0003000F3O00202O00030003001000122O0004000F3O00202O00040004001000122O0005000F3O00202O0005000500104O00020005000200102O0001000D00024O00015O00202O00010001000300202O00010001000400122O000200123O00102O00010011000200124O00073O00044O000100012O002A3O00017O000E3O002O0103053O00706169727303043O0067616D6503073O00506C6179657273030A3O00476574506C617965727303043O004E616D65030B3O004C6F63616C506C617965722O033O00455350030B3O004765744368696C6472656E03063O00737472696E672O033O00737562026O0010C003043O005F45535003073O0044657374726F79012C4O003500018O000100016O00018O00015O00262O0001001A0001000100042D3O001A0001001254000100023O00125B000200033O00202O00020002000400202O0002000200054O000200036O00013O000300044O00170001002040000600050006001218000700033O00202O00070007000400202O00070007000700202O00070007000600062O000600170001000700042D3O00170001001254000600084O0028000700054O00300006000200010006430001000D0001000200042D3O000D000100042D3O002B0001001254000100024O0011000200013O00202O0002000200094O000200036O00013O000300044O002900010012540006000A3O00200300060006000B00202O00070005000600122O0008000C6O00060008000200262O000600290001000D00042D3O0029000100201D00060005000E2O0030000600020001000643000100200001000200042D3O002000012O002A3O00017O00033O00028O00026O00F03F03063O0061696D626F7401163O00123C000100014O0039000200023O002661000100020001000100042D3O0002000100123C000200013O0026610002000C0001000200042D3O000C00012O003A00036O003600036O003A00036O0036000300013O00042D3O00150001002661000200050001000100042D3O000500010012013O00034O003A00036O0036000300023O00123C000200023O00042D3O0005000100042D3O0015000100042D3O000200012O002A3O00017O00113O00030D3O0055736572496E7075745479706503043O00456E756D030C3O004D6F75736542752O746F6E3203063O0061696D626F742O01028O00026O00F03F03113O0046696E644E656172657374506C6179657203043O007461736B03043O0077616974023O00A0F7C6B03E0003103O0048756D616E6F6964522O6F745061727403063O00434672616D6503083O0056656C6F6369747903063O006C2O6F6B417403083O00506F736974696F6E01613O00200700013O000100122O000200023O00202O00020002000100202O00020002000300062O000100600001000200042D3O00600001001254000100043O002661000100600001000500042D3O0060000100123C000100063O002661000100110001000600042D3O001100012O003A000200014O003600026O003A000200014O0036000200013O00123C000100073O0026610001000A0001000700042D3O000A00012O003A000200014O0036000200024O0055000200013O0006420002006000013O00042D3O0060000100123C000200064O0039000300033O0026610002001A0001000600042D3O001A0001001254000400084O001E0004000100022O0028000300044O005500045O0006420004006000013O00042D3O0060000100123C000400064O0039000500053O002661000400240001000600042D3O0024000100123C000500063O002661000500270001000600042D3O00270001001254000600093O00205000060006000A00122O0007000B6O0006000200014O000600023O00062O0006001F00013O00042D3O001F00010026600003001F0001000C00042D3O001F000100123C000600064O0039000700073O002661000600510001000600042D3O0051000100123C000800063O000E4D0006004C0001000800042D3O004C000100204000090003000D00202700090009000E00202O000A0003000D00202O000A000A000F4O000B00036O000A000A000B4O00090009000A4O000A00046O00070009000A4O000900053O00122O000A000E3O00202O000A000A00104O000B00053O00202O000B000B000E00202O000B000B001100202O000C000700114O000A000C000200102O0009000E000A00122O000800073O002661000800370001000700042D3O0037000100123C000600073O00042D3O0051000100042D3O00370001002661000600340001000700042D3O003400012O0055000800064O004F00080001000100042D3O001F000100042D3O0034000100042D3O001F000100042D3O0027000100042D3O001F000100042D3O0024000100042D3O001F000100042D3O0060000100042D3O001A000100042D3O0060000100042D3O000A00012O002A3O00017O00033O00030D3O0055736572496E7075745479706503043O00456E756D030C3O004D6F75736542752O746F6E3201093O00200700013O000100122O000200023O00202O00020002000100202O00020002000300062O000100080001000200042D3O000800012O005500016O004F0001000100012O002A3O00017O00073O00028O002O033O004A2O4B0100030C3O007472616E73706172656E6379026O00F03F2O0102AE47E17A14AEEF3F011A3O00123C000100014O0039000200023O000E4D000100020001000100042D3O0002000100123C000200013O002661000200050001000100042D3O00050001001254000300024O0005000300033O001201000300023O001254000300023O002661000300100001000300042D3O0010000100123C000300053O001201000300043O00042D3O00190001001254000300023O002661000300190001000600042D3O0019000100123C000300073O001201000300043O00042D3O0019000100042D3O0005000100042D3O0019000100042D3O000200012O002A3O00017O00033O00028O002O033O002O736B03073O0056697369626C65010C3O00123C000100013O002661000100010001000100042D3O00010001001254000200024O0038000200023O00122O000200026O00025O00122O000300023O00102O00020003000300044O000B000100042D3O000100012O002A3O00017O00013O0003063O0052616469757301034O005500015O00102O000100014O002A3O00017O00063O00028O0003063O00436F6C6F723303073O0066726F6D52474203053O007072696E74030D3O00696E76616C696420636F6C6F7203053O00436F6C6F7201143O00123C000100014O0039000200023O002661000100020001000100042D3O00020001001254000300023O00202C0003000300034O00048O0003000200024O000200033O00062O0002000F0001000100042D3O000F0001001254000300043O00123C000400054O003000030002000100042D3O001300012O005500035O00102O00030006000200042D3O0013000100042D3O000200012O002A3O00017O00053O00028O00030E3O0046696E6446697273744368696C6403103O0048756D616E6F6964522O6F745061727403053O00546F72736F030A3O00552O706572546F72736F01193O00123C000100014O0039000200023O000E4D000100020001000100042D3O0002000100123C000300013O002661000300050001000100042D3O0005000100201D00043O000200123C000600034O0008000400060002000614000200150001000400042D3O0015000100201D00043O000200123C000600044O0008000400060002000614000200150001000400042D3O0015000100201D00043O000200123C000600054O00080004000600022O0028000200044O0009000200023O00042D3O0005000100042D3O000200012O002A3O00017O00053O00028O00026O00244003043O006D61746803053O00666C2O6F72026O00E03F02153O00123C000200014O0039000300033O000E4D000100020001000200042D3O0002000100123C000400013O002661000400050001000100042D3O000500010006140005000A0001000100042D3O000A000100123C000500013O001016000300020005001262000500033O00202O0005000500044O00063O000300202O0006000600054O0005000200024O0005000500034O000500023O00044O0005000100042D3O000200012O002A3O00017O00023O0003043O007461736B03053O00737061776E010A3O001254000100013O00204000010001000200065100023O000100052O00558O00288O00553O00014O00553O00024O00553O00034O00300001000200012O002A3O00013O00013O003C3O00028O0003053O007061697273030B3O004765744368696C6472656E03043O004E616D6503043O005F45535003073O0044657374726F7903043O0077616974026O00F03F03093O00436861726163746572030B3O004C6F63616C506C61796572030E3O0046696E6446697273744368696C6403083O00496E7374616E63652O033O006E657703063O00466F6C64657203063O00506172656E7403073O00676574522O6F7403153O0046696E6446697273744368696C644F66436C612O7303083O0048756D616E6F69642O033O0049734103083O00426173655061727403123O00426F7848616E646C6541646F726E6D656E74027O0040030B3O00416C776179734F6E546F702O0103063O005A496E646578026O002440026O000840026O00104003053O00436F6C6F7203093O005465616D436F6C6F7203043O0053697A65030C3O005472616E73706172656E637902295C8FC2F528EC3F03073O0041646F726E2O6503043O0048656164030C3O0042692O6C626F61726447756903093O00546578744C6162656C03053O005544696D32026O005940025O00C06240030B3O0053747564734F2O6673657403073O00566563746F723303163O004261636B67726F756E645472616E73706172656E637903083O00506F736974696F6E026O0049C003043O00466F6E7403043O00456E756D03123O00536F7572636553616E7353656D69626F6C6403083O005465787453697A65026O003440030A3O0054657874436F6C6F723303063O00436F6C6F723303163O00546578745374726F6B655472616E73706172656E6379030E3O005465787459416C69676E6D656E7403063O00426F2O746F6D03043O005465787403063O004E616D653A20030E3O00436861726163746572412O64656403073O00436F2O6E656374030D3O0052656E6465725374652O70656400F43O00123C3O00013O0026613O00170001000100042D3O00170001001254000100024O001100025O00202O0002000200034O000200036O00013O000300044O001200010020400006000500042O000D000700013O00202O00070007000400122O000800056O00070007000800062O000600120001000700042D3O0012000100201D0006000500062O0030000600020001000643000100090001000200042D3O00090001001254000100074O004F00010001000100123C3O00083O0026613O00010001000800042D3O000100012O0055000100013O002040000100010009000642000100F300013O00042D3O00F300012O0055000100013O0020570001000100044O000200023O00202O00020002000A00202O00020002000400062O000100F30001000200042D3O00F300012O005500015O00202F00010001000B4O000300013O00202O00030003000400122O000400056O0003000300044O00010003000200062O000100F30001000100042D3O00F300010012540001000C3O00204A00010001000D00122O0002000E6O0001000200024O000200013O00202O00020002000400122O000300056O00020002000300102O0001000400024O00025O00102O0001000F0002001254000200073O001215000300086O0002000200014O000200013O00202O00020002000900062O0002003800013O00042D3O00380001001254000200104O0055000300013O0020400003000300092O00670002000200020006420002003800013O00042D3O003800012O0055000200013O00202100020002000900202O00020002001100122O000400126O00020004000200062O0002003800013O00042D3O00380001001254000200024O0034000300013O00202O00030003000900202O0003000300034O000300046O00023O000400044O007C000100201D00070006001300123C000900144O00080007000900020006420007007C00013O00042D3O007C000100123C000700014O0039000800083O000E4D000100650001000700042D3O006500010012540009000C3O00201F00090009000D00122O000A00156O0009000200024O000800096O000900013O00202O00090009000400102O00080004000900122O000700083O0026610007006A0001001600042D3O006A000100305F00080017001800305F00080019001A00123C0007001B3O002661000700700001001C00042D3O007000012O0055000900013O00204000090009001E00102O0008001D000900042D3O007C0001002661000700760001001B00042D3O0076000100204000090006001F00102O0008001F000900305F00080020002100123C0007001C3O0026610007005A0001000800042D3O005A000100102O0008000F000100102O00080022000600123C000700163O00042D3O005A0001000643000200530001000200042D3O005300012O0055000200013O002040000200020009000642000200F000013O00042D3O00F000012O0055000200013O00202100020002000900202O00020002000B00122O000400236O00020004000200062O000200F000013O00042D3O00F000010012540002000C3O00202B00020002000D00122O000300246O00020002000200122O0003000C3O00202O00030003000D00122O000400256O0003000200024O000400013O00202O00040004000900202O00040004002300102O0002002200044O000400013O00202O00040004000400102O00020004000400102O0002000F000100122O000400263O00202O00040004000D00122O000500013O00122O000600273O00122O000700013O00122O000800286O00040008000200102O0002001F000400122O0004002A3O00202O00040004000D00122O000500013O00122O000600083O00122O000700016O00040007000200102O00020029000400302O00020017001800102O0003000F000200302O0003002B000800122O000400263O00202O00040004000D00122O000500013O00122O000600013O00122O000700013O00122O0008002D6O00040008000200102O0003002C000400122O000400263O00202O00040004000D00122O000500013O00122O000600273O00122O000700013O00122O000800276O00040008000200102O0003001F000400122O0004002F3O00202O00040004002E00202O00040004003000102O0003002E000400302O00030031003200122O000400343O00202O00040004000D00122O000500083O00122O000600083O00122O000700086O00040007000200102O00030033000400302O00030035000100122O0004002F3O00202O00040004003600202O00040004003700102O00030036000400122O000400396O000500013O00202O0005000500044O00040004000500102O00030038000400302O00030019001A4O000400056O000600013O00202O00060006003A00202O00060006003B00065100083O000100052O00553O00034O00553O00014O00283O00054O00283O00044O00283O00014O00080006000800022O0028000500063O00065100060001000100072O00558O00553O00014O00553O00034O00553O00024O00283O00034O00283O00054O00283O00044O0055000700033O002661000700EF0001001800042D3O00EF00012O0055000700043O00200200070007003C00202O00070007003B4O000900066O0007000900024O000400074O002000026O002000015O00042D3O00F3000100042D3O000100012O002A3O00013O00023O000C3O002O01028O00026O00F03F03043O007761697403073O00676574522O6F7403093O0043686172616374657203153O0046696E6446697273744368696C644F66436C612O7303083O0048756D616E6F69642O033O00455350027O0040030A3O00446973636F2O6E65637403073O0044657374726F79002F4O00557O0026613O002B0001000100042D3O002B000100123C3O00023O0026613O001A0001000300042D3O001A0001001254000100043O001226000200036O00010002000100122O000100056O000200013O00202O0002000200064O00010002000200062O0001000600013O00042D3O000600012O0055000100013O00202100010001000600202O00010001000700122O000300086O00010003000200062O0001000600013O00042D3O00060001001254000100094O0055000200014O003000010002000100123C3O000A3O0026613O00200001000A00042D3O002000012O0055000100023O00201D00010001000B2O003000010002000100042D3O002E00010026613O00040001000200042D3O000400012O0055000100033O00206500010001000B4O0001000200014O000100043O00202O00010001000C4O00010002000100124O00033O00044O0004000100042D3O002E00012O00553O00023O00201D5O000B2O00303O000200012O002A3O00017O00163O00030E3O0046696E6446697273744368696C6403043O004E616D6503043O005F4553502O0103093O0043686172616374657203073O00676574522O6F7403153O0046696E6446697273744368696C644F66436C612O7303083O0048756D616E6F6964030B3O004C6F63616C506C6179657203043O006D61746803053O00666C2O6F7203083O00506F736974696F6E03093O006D61676E697475646503043O005465787403063O004E616D653A20030B3O00207C204865616C74683A2003053O00726F756E6403063O004865616C7468026O00F03F030A3O00207C2053747564733A20028O00030A3O00446973636F2O6E65637400604O002E7O00206O00014O000200013O00202O00020002000200122O000300036O0002000200036O0002000200064O005400013O00042D3O005400012O00553O00023O0026613O00540001000400042D3O005400012O00553O00013O0020405O00050006423O005F00013O00042D3O005F00010012543O00064O0055000100013O0020400001000100052O00673O000200020006423O005F00013O00042D3O005F00012O00553O00013O0020215O000500206O000700122O000200088O0002000200064O005F00013O00042D3O005F00012O00553O00033O0020405O00090020405O00050006423O005F00013O00042D3O005F00010012543O00064O0047000100033O00202O00010001000900202O0001000100056O0002000200064O005F00013O00042D3O005F00012O00553O00033O0020665O000900206O000500206O000700122O000200088O0002000200064O005F00013O00042D3O005F00010012543O000A3O00201C5O000B00122O000100066O000200033O00202O00020002000900202O0002000200054O00010002000200202O00010001000C00122O000200066O000300013O00202O0003000300054O00020002000200202O00020002000C4O00010001000200202O00010001000D6O000200024O000100043O00122O0002000F6O000300013O00202O00030003000200122O000400103O00122O000500116O000600013O00202O00060006000500202O00060006000700122O000800086O00060008000200202O00060006001200122O000700136O00050007000200122O000600146O00078O00020002000700102O0001000E000200044O005F000100123C3O00153O0026613O00550001001500042D3O005500012O0055000100053O0020590001000100164O0001000200014O000100063O00202O0001000100164O00010002000100044O005F000100042D3O005500012O002A3O00017O00153O0003043O006D61746803043O006875676503053O007061697273030A3O00476574506C617965727303093O00436861726163746572030E3O0046696E6446697273744368696C6403083O0048756D616E6F696403063O004865616C7468028O0003103O0048756D616E6F6964522O6F7450617274026O00F03F03073O00566563746F72322O033O006E657703013O005803013O005903093O004D61676E697475646503063O0052616469757303143O00576F726C64546F56696577706F7274506F696E7403023O005F4703073O0041696D5061727403083O00506F736974696F6E005B3O0012333O00013O00206O00024O000100013O00122O000200036O00035O00202O0003000300044O000300046O00023O000400044O005700012O0055000700013O00063B000600570001000700042D3O0057000100204000070006000500201D00070007000600123C000900074O00080007000900020006420007005700013O00042D3O0057000100204000070006000500200E00070007000600122O000900076O00070009000200202O000700070008000E2O000900570001000700042D3O0057000100204000070006000500201D00070007000600123C0009000A4O00080007000900020006420007005700013O00042D3O005700010006420006005700013O00042D3O0057000100123C000700094O00390008000A3O000E4D000B00490001000700042D3O00490001000642000A005700013O00042D3O00570001001254000B000C3O002025000B000B000D4O000C00023O00202O000C000C000E4O000D00023O00202O000D000D000F4O000B000D000200122O000C000C3O00202O000C000C000D00202O000D0009000E00202O000E0009000F4O000C000E00024O000B000B000C00202O000B000B001000062O000B005700013O00042D3O005700012O0055000C00033O002040000C000C0011000619000B00570001000C00042D3O0057000100123C000C00094O0039000D000D3O002661000C003D0001000900042D3O003D000100123C000D00093O002661000D00400001000900042D3O004000012O00283O000B4O0028000100083O00042D3O0057000100042D3O0040000100042D3O0057000100042D3O003D000100042D3O00570001002661000700230001000900042D3O002300010020400008000600052O005C000B00043O00202O000B000B001200122O000D00133O00202O000D000D00144O000D0008000D00202O000D000D00154O000B000D000C4O000A000C6O0009000B3O00122O0007000B3O00044O00230001000643000200090001000200042D3O000900012O0009000100024O002A3O00017O00", GetFEnv(), ...);
