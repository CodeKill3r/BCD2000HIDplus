function BCD() {
}

BCD.debug = true;
BCD.escratch = [false, false];

//sensitivity setting
BCD.UseAcceleration = true;
BCD.JogSensitivity = 0.2;

BCD.shift = false


BCD.init = function (id) { // called when the device is opened & set up

    BCD.reset();

    // TEST : try to activate microphone instead of analog 1 on
    //midi.sendShortMsg(0xC0, 0x01, 2);

    // Ask BCD to send the current values of all rotary knobs and sliders
    midi.sendShortMsg(0xB0, 0x64, 0x7F);

    // Set jog acceleration
    if (BCD.UseAcceleration)
        midi.sendShortMsg(0xB0, 0x63, 0x7F);
    else
        midi.sendShortMsg(0xB0, 0x63, 0x0);
};

BCD.shutdown = function () {

    BCD.reset();

    // Re-enable jog acceleration
    if (!BCD.UseAcceleration)
        midi.sendShortMsg(0xB0, 0x63, 0x7F);
};

BCD.reset = function () {

    midi.sendShortMsg(0xB1, 0x13, 0x00);

    // Turn off all the lights
    // for (i = 1; i <= 25; i++) {
    //     midi.sendShortMsg(0xB0, i, 0);
    // }

    function sendMidiMessage() {
        for (var i = 1; i <= 25; i++) {
            engine.beginTimer(i * 100, function() {
                midi.sendShortMsg(0xB0, i, 0);
            }, true);
        }
    }
};

BCD.getDeck = function (group) {
    if (group == "[Channel1]")
        return 0;
    else if (group == "[Channel2]")
        return 1;

    print("Invalid group : " + group);
    return -1; // error
}

/*
BehringerBCD2000.shifter = {
    longPressTimer: 0,
    input: function (channel, control, value, status, group) {
        if (value) {
            this.onPress(channel, control, value, status, group)
            this.longPressTimer = engine.beginTimer(250, function () {
                this.longPressTimer = 0;
            }, true);
        } else if (this.longPressTimer !== 0) {
            // Button released after short press
            engine.stopTimer(this.longPressTimer);
            this.longPressTimer = 0;
        } else {
            // Button released after long press
            this.onPress(channel, control, 0x7F, status, group)
        }
    },
    onPress: function (channel, control, value, status, group) {
        BehringerBCD2000.shift ^= (value == 0x7F)
        midi.sendShortMsg(0xB0, 0x07,
            BehringerBCD2000.shift ? 0x7F : 0x00)
    },
}
*/

BCD.talkOver = function (channel, control, value, status, group) {
    midi.sendShortMsg(0xB0, 0x63, value)
    // <status>0xB0</status>
    // <midino>0x08</midino>

}

BCD.shifter = {
    input: function (channel, control, value, status, group) {
        BCD.shift = (value == 0x7F)
        midi.sendShortMsg(0xB0, 0x07, value)
        if (!value) {
            engine.setParameter('[Library]', 'GoToItem', 1);
        }
    }
}

//Scratch, cue search and pitch bend function
BCD.jogWheel = function (channel, control, value, status, group) {
    var deck = BCD.getDeck(group)
    var forward = value >= 65
    var adjustedValue = value - (forward ? 0x40 : 0x41)

    if (BCD.shift) {
        var action = forward ? 'SelectNext' : 'SelectPrev'
        var list = deck == 0 ? 'Playlist' : 'Track'
        engine.setValue("[Playlist]", action + list, 1);

    } else if (BCD.escratch[deck]) {
        engine.scratchTick(deck + 1, adjustedValue);
        if (BCD.debug) print(group + " scratch tick : " + adjustedValue);

    } else {
        var jogValue = adjustedValue * BCD.JogSensitivity;
        engine.setValue(group, "jog", jogValue);
        if (BCD.debug) print(group + " pitching jog adjust : " + jogValue);
    }
};

//Scratch button function
BCD.scratchButton = function (channel, control, value, status, group) {

    if (value != 0x7F)
        return;

    var deck = BCD.getDeck(group);
    var a = deck == 0 ? 0x13 : 0x0B

    BCD.escratch[deck] = !BCD.escratch[deck];

    if (BCD.debug)
        print(group + " scratch enabled :" + BCD.escratch[deck]);

    if (BCD.escratch[deck]) {
        // Turn on the scratch light
        midi.sendShortMsg(0xB0, a, 0x7F);
        // Enable scratching
        engine.scratchEnable(deck + 1, 100, 33 + 1 / 3, 1.0 / 8, (1.0 / 8) / 32);

    } else {
        // Turn off the scratch light
        midi.sendShortMsg(0xB0, a, 0x00);
        // Disable scratching
        engine.scratchDisable(deck + 1);
    }
};

//Set loop function
BCD.loop = function (channel, control, value, status, group) {
    if (value)
        action = "loop_in";
    else
        action = "loop_out";

    if (BCD.debug)
        print(group + " " + action);

    engine.setValue(group, action, 1);
};

//Effect Unit function
BCD.effectUnit = new components.EffectUnit([1, 3]);
BCD.effectUnit.enableButtons[1].midi = [0x90, 0x1F];
BCD.effectUnit.enableButtons[2].midi = [0x90, 0x20];
BCD.effectUnit.enableButtons[3].midi = [0x90, 0x21];
BCD.effectUnit.knobs[1].midi = [0xB0, 0x0D];
BCD.effectUnit.knobs[2].midi = [0xB0, 0x0E];
BCD.effectUnit.knobs[3].midi = [0xB0, 0x0F];
BCD.effectUnit.dryWetKnob.midi = [0xB0, 0x10];
BCD.effectUnit.effectFocusButton.midi = [0x90, 0x22];
BCD.effectUnit.init();