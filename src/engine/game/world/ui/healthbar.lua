local HealthBar, super = Class(Object)

function HealthBar:init()
    super:init(self, 0, -80)

    self.layer = 1 -- TODO

    self.parallax_x = 0
    self.parallax_y = 0

    self.animation_done = false
    self.animation_timer = 0
    self.animate_out = false

    self.selected_submenu = 1

    -- States: MAIN, ITEMMENU, ITEMSELECT, KEYSELECT, PARTYSELECT,
    -- EQUIPMENU, WEAPONSELECT, REPLACEMENTSELECT, POWERMENU, SPELLSELECT,
    -- CONFIGMENU, VOLUMESELECT, CONTROLSMENU, CONTROLSELECT
    self.state = "MAIN"
    self.heart_sprite = Assets.getTexture("player/heart")

    self.ui_move = Assets.newSound("ui_move")
    self.ui_select = Assets.newSound("ui_select")

    self.font = Assets.getFont("main")
    self.action_font = Assets.getFont("smallnumbers")

    self.desc_sprites = {
        Assets.getTexture("ui/menu/desc/item"),
        Assets.getTexture("ui/menu/desc/equip"),
        Assets.getTexture("ui/menu/desc/power"),
        Assets.getTexture("ui/menu/desc/config")
    }

    self.buttons = {
        {Assets.getTexture("ui/menu/btn/item"  ), Assets.getTexture("ui/menu/btn/item_h"  ), Assets.getTexture("ui/menu/btn/item_s"  )},
        {Assets.getTexture("ui/menu/btn/equip" ), Assets.getTexture("ui/menu/btn/equip_h" ), Assets.getTexture("ui/menu/btn/equip_s" )},
        {Assets.getTexture("ui/menu/btn/power" ), Assets.getTexture("ui/menu/btn/power_h" ), Assets.getTexture("ui/menu/btn/power_s" )},
        {Assets.getTexture("ui/menu/btn/config"), Assets.getTexture("ui/menu/btn/config_h"), Assets.getTexture("ui/menu/btn/config_s")}
    }

    self.action_boxes = {}

    for index, chara in ipairs(Game.party) do
        local x_pos = (index - 1) * 213

        if #Game.party == 2 then
            if index == 1 then
                x_pos = 108
            else
                x_pos = 322
            end
        elseif #Game.party == 1 then
            x_pos = 213
        end

        local action_box = OverworldActionBox(x_pos, 0, index, chara)
        self:addChild(action_box)
        table.insert(self.action_boxes, action_box)
    end

    self.auto_hide_timer = 0
end

function HealthBar:transitionOut()
    self.animate_out = true
    self.animation_timer = 0
    self.animation_done = false
end


function HealthBar:update(dt)
    self.animation_timer = self.animation_timer + DTMULT
    self.auto_hide_timer = self.auto_hide_timer + DTMULT
    if Game.world.menu or Game.world.in_battle then
        -- If we're in an overworld battle, or the menu is open, we don't want the health bar to disappear
        self.auto_hide_timer = 0
    end

    if self.auto_hide_timer > 60 then -- After two seconds outside of a battle, we hide the health bar
        self:transitionOut()
    end

    local max_time = self.animate_out and 3 or 8

    if self.animation_timer > max_time + 1 then
        self.animation_done = true
        self.animation_timer = max_time + 1
        if self.animate_out then
            Game.world.healthbar = nil
            self:remove()
            return
        end
    end

    if not self.animate_out then
        self.y = Ease.outCubic(math.min(max_time, self.animation_timer), 417 + 63, -63, max_time)
    else
        self.y = Ease.outCubic(math.min(max_time, self.animation_timer), 417, 63, max_time)
    end

    super:update(self, dt)
end

function HealthBar:draw()
    -- Draw the black background
    love.graphics.setColor(0, 0, 0, 1)
    love.graphics.rectangle("fill", 0, 2, 640, 61)

    super:draw(self)
end

return HealthBar