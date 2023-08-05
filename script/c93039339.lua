--Stellar Nemesis T-PHON - Doomsday Star
local s,id,o=GetID()
local special_count = {}
function s.initial_effect(c)
	c:EnableReviveLimit()
	--material
	aux.AddXyzProcedure(c,nil,12,2)
	s.AddMaxXyzProcedure(c)
	if not s.global_check then
		s.global_check=true
		local ge1=Effect.GlobalEffect(c)
		ge1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		ge1:SetCode(EVENT_SPSUMMON_SUCCESS)
		ge1:SetOperation(s.chcon)
		ge1:SetOperation(s.chop)
		Duel.RegisterEffect(ge1,0)
	end
	--limit effects
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_CANNOT_ACTIVATE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e2:SetTargetRange(1,1)
	e2:SetCondition(s.lecon)
	e2:SetValue(s.actlimit)
	c:RegisterEffect(e2)
	--to hand
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,1))
	e3:SetCategory(CATEGORY_TOHAND)
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCountLimit(1)
	e3:SetCost(s.thcost)
	e3:SetTarget(s.thtg)
	e3:SetOperation(s.thop)
	c:RegisterEffect(e3)
end
function s.lsop(e,tp,eg,ep,ev,re,r,rp)
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetDescription(aux.Stringid(id,3))
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_CLIENT_HINT)
	e1:SetTargetRange(1,0)
	e1:SetReset(RESET_PHASE+PHASE_END)
	Duel.RegisterEffect(e1,tp)
	local e2=e1:Clone()
	e2:SetDescription(aux.Stringid(id,3))
	e2:SetCode(EFFECT_CANNOT_SUMMON)
	Duel.RegisterEffect(e2,tp)
	e:Reset()
end
function s.lecon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_XYZ)
end
function s.actlimit(e,re,tp)
	return re:IsActiveType(TYPE_MONSTER) and re:GetHandler():IsAttackAbove(3000)
end
function s.thcost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:CheckRemoveOverlayCard(tp,1,REASON_COST) end
	c:RemoveOverlayCard(tp,1,1,REASON_COST)
end
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	local g=Duel.GetMatchingGroup(Card.IsAbleToHand,tp,LOCATION_MZONE,LOCATION_MZONE,nil)
	if chk==0 then return #g>0 end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,1,0,0)
end
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RTOHAND)
	local g=Duel.SelectMatchingCard(tp,Card.IsAbleToHand,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
	Duel.SendtoHand(g,nil,REASON_EFFECT)
end
function s.chcon(e,tp,eg,ev,ep,re,r,rp)
	return eg:IsExists(s.cf,1,nil)
end
function s.cf(c,tp)
	return c:IsPreviousLocation(LOCATION_EXTRA)
end
function s.chop(e,tp,eg,ev,ep,re,r,rp)
	if eg:IsExists(s.cf,1,nil) then
		local turn = Duel.GetTurnCount()
		if not special_count[1-ep] then special_count[1-ep]={} end
		if not special_count[1-ep][turn] then special_count[1-ep][turn]=0 end
		special_count[1-ep][turn]=special_count[1-ep][turn]+1
	end
end
function s.AddMaxXyzProcedure(c)
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(1165)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_SPSUMMON_PROC)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetRange(LOCATION_EXTRA)
	e1:SetCondition(s.xyzcon)
	e1:SetTarget(s.xyztg)
	e1:SetOperation(s.xyzop)
	e1:SetValue(SUMMON_TYPE_XYZ)
	c:RegisterEffect(e1)
	return e1
end
function s.xyzcon(e,c,og)
		if c==nil then return true end
		local tp=c:GetControler()
		local turn=Duel.GetTurnCount()
		if not special_count[tp] then return false end
		if not special_count[tp][turn] and not special_count[tp][turn-1] then return false end
		local the_true=2
		if (special_count[tp][turn] and special_count[tp][turn]<2) or not  special_count[tp][turn] then the_true=the_true-1 end
		if (special_count[tp][turn-1] and special_count[tp][turn-1]<2) or not special_count[tp][turn-1] then the_true=the_true-1 end
		if the_true==0 then return false else the_true=nil end
		local g=nil
		if og then g=og else g=Duel.GetFieldGroup(tp,LOCATION_MZONE,0) end
		local ct=0
		if #g>0 then a,ct=g:GetMaxGroup(Card.GetAttack) end
		return g:CheckSubGroup(s.MaxXyzGoal,1,1,tp,c,ct)
end
function s.xyztg(e,tp,og)
		local c=e:GetHandler()
		local turn=Duel.GetTurnCount()
		if not special_count[tp] then return false end
		if not special_count[tp][turn] and not special_count[tp][turn-1] then return false end
		local the_true=2
		if (special_count[tp][turn] and special_count[tp][turn]<2) or not  special_count[tp][turn] then the_true=the_true-1 end
		if (special_count[tp][turn-1] and special_count[tp][turn-1]<2) or not special_count[tp][turn-1] then the_true=the_true-1 end
		if the_true==0 then return false else the_true=nil end
		local g=nil
		 if og then g=og else g=Duel.GetFieldGroup(tp,LOCATION_MZONE,0) end
		local cancel=Duel.IsSummonCancelable()
		aux.GCheckAdditional=aux.TuneMagicianCheckAdditionalX(EFFECT_TUNE_MAGICIAN_X)
		Duel.Hint(3,tp,513)
		local ct=0
		if #g>0 then a,ct=g:GetMaxGroup(Card.GetAttack) end
		local mg=g:SelectSubGroup(tp,s.MaxXyzGoal,cancel,1,1,tp,c,ct)
		aux.GCheckAdditional=nil
		if mg and mg:GetCount()>0 then
			mg:KeepAlive()
			e:SetLabelObject(mg)
			return true
		else return false end
end
function s.xyzop(e,tp,og)
		local c=e:GetHandler()
		local g=e:GetLabelObject()
		local sg=g:Filter(Card.IsType,nil,TYPE_XYZ)
		if #g>0 then
			local tc=sg:GetFirst()
			while tc do
				local ag=tc:GetOverlayGroup()
				if #ag>0 then
					g:Merge(ag)
				end
				tc=sg:GetNext()
			end
		end
		c:SetMaterial(g)
		Duel.Overlay(c,g)
		g:DeleteGroup()
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
		e1:SetCode(EVENT_SPSUMMON_SUCCESS)
		e1:SetProperty(EFFECT_FLAG_UNCOPYABLE)
		e1:SetOperation(s.lsop)
		c:RegisterEffect(e1)
end
function s.MaxXyzGoal(g,tp,xyzc,ct)
	local sg=Duel.GetMustMaterial(tp,EFFECT_MUST_BE_XMATERIAL)
	if sg:IsExists(aux.MustMaterialCounterFilter,1,nil,g) or g:IsExists(function(c) return not c:IsCanBeXyzMaterial(xyzc) end,1,nil) then return false end
	return g:IsExists(Card.IsAttack,nil,1,ct)
end