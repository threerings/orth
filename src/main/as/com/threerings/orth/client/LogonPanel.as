//
// $Id: $

package com.threerings.orth.client {
import com.threerings.orth.ui.FloatingPanel;

import flash.events.Event;

import mx.containers.HBox;
import mx.containers.VBox;

import mx.controls.Label;

import mx.controls.Text;
import mx.controls.TextInput;
import mx.core.UITextField;
import mx.events.FlexEvent;

import com.adobe.crypto.MD5;

import com.threerings.util.CommandEvent;
import com.threerings.util.Log;
import com.threerings.util.Name;
import com.threerings.util.StringUtil;

import com.threerings.flex.CommandButton;
import com.threerings.flex.FlexUtil;

import com.threerings.presents.client.ClientAdapter;
import com.threerings.presents.client.ClientEvent;

import com.threerings.orth.aether.data.AetherCredentials;

public class LogonPanel extends FloatingPanel
{
    public function LogonPanel (ctx :OrthContext)
    {
        super(ctx, Msgs.GENERAL.get("t.logon"));
    }

    override protected function createChildren () :void
    {
        super.createChildren();
        setStyle("horizontalAlign", "left");
        setStyle("verticalAlign", "middle");
        showCloseButton = true;

        const left :VBox = new VBox();
        left.percentHeight = 100;
        createLogonChildren(left);

        //const sep :Spacer = FlexUtil.createSpacer(1);
        const sep :VBox = new VBox();
        sep.width = 1;
        sep.percentHeight = 90;
        sep.setStyle("borderStyle", "solid");
        sep.setStyle("borderSides", "right");
        sep.setStyle("borderThickness", 1);
        sep.setStyle("borderColor", 0x0d4c77);

        const right :VBox = new VBox();
        right.percentHeight = 100;
        createRegisterChildren(right);

        const panel :HBox = new HBox();
        panel.addChild(left);
        panel.addChild(sep);
        panel.addChild(right);
        addChild(panel);
    }

    protected function createLogonChildren (box :VBox) :void
    {
        var label :UITextField = new UITextField();
        label.text = Msgs.GENERAL.get("l.username");
        box.addChild(label);

        _username = new TextInput();
        _username.text = Prefs.getUsername();
        box.addChild(_username);

        label = new UITextField();
        label.text = Msgs.GENERAL.get("l.password");
        box.addChild(label);

        _password = new TextInput();
        _password.displayAsPassword = true;
        box.addChild(_password);

        _username.addEventListener(Event.CHANGE, checkTexts);
        _password.addEventListener(Event.CHANGE, checkTexts);
        _password.addEventListener(FlexEvent.ENTER, doLogon);

        _logonBtn = new CommandButton(null, doLogon);
        _logonBtn.styleName = "logonButton";

        var buttons :HBox = new HBox();
        buttons.percentWidth = 100;
        buttons.setStyle("horizontalAlign", "right");
        buttons.addChild(_logonBtn);
        box.addChild(buttons);

        _error = new Label();
        FlexUtil.setVisible(_error, false);
        box.addChild(_error);

        checkTexts();
    }

    protected function createRegisterChildren (box :VBox) :void
    {
        box.setStyle("horizontalAlign", "center");
        box.setStyle("verticalAlign", "middle");

        const prompt :Text = FlexUtil.createText(Msgs.GENERAL.get("p.sign_up"), 200);
        prompt.setStyle("fontSize", 18);
        prompt.setStyle("textAlign", "center");
        box.addChild(prompt);

        const joinBtn :CommandButton = new CommandButton(null, OrthController.SHOW_SIGN_UP);
        joinBtn.styleName = "joinNowButton";
        box.addChild(joinBtn);
    }

    /**
     * Are the username/password fields non-blank such that we can attempt logon?
     */
    protected function canTryLogon () :Boolean
    {
        return (!StringUtil.isBlank(_username.text) && !StringUtil.isBlank(_password.text));
    }

    /**
     * Handles Event.CHANGE events from the text input fields.
     */
    protected function checkTexts (...ignored) :void
    {
        _logonBtn.enabled = canTryLogon();
    }

    /**
     * Handles FlexEvent.ENTER or FlexEvent.BUTTON_DOWN events generated to process a logon.
     */
    protected function doLogon (...ignored) :void
    {
        if (!canTryLogon()) {
            // we disable the button, but they could still try pressing return in the password
            // field, and I don't want to mess with adding/removing the listener in checkTexts
            return;
        }

        _logonBtn.enabled = false;

        _observer = new ClientAdapter(null, didLogon, null, null, failed, failed);
        _ctx.getClient().addClientObserver(_observer);

        var creds :AetherCredentials = new AetherCredentials(
            new Name(_username.text), MD5.hash(_password.text));
        CommandEvent.dispatch(this, OrthController.LOGON, creds);
    }

    protected function didLogon (...ignored) :void
    {
        close();

        _ctx.getClient().removeClientObserver(_observer);
    }

    protected function failed (evt :ClientEvent) :void
    {
        evt.getClient().removeClientObserver(_observer);

        Log.getLog(this).debug("failed: " + Msgs.GENERAL.get(evt.getCause().message));
        _error.text = "Logon failed: " + Msgs.GENERAL.get(evt.getCause().message);
        FlexUtil.setVisible(_error, true);
        _logonBtn.enabled = true;
    }

    protected var _username :TextInput;
    protected var _password :TextInput;
    protected var _error :Label;

    protected var _logonBtn :CommandButton;

    protected var _observer :ClientAdapter;
}
}
