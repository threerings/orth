//
// $Id: ControlBar.as 19594 2010-11-19 16:47:28Z zell $

package com.threerings.orth.client {

import flash.events.Event;
import flash.utils.Dictionary;

import flashx.funk.ioc.inject;

import mx.containers.HBox;
import mx.core.ScrollPolicy;
import mx.core.UIComponent;

import com.threerings.display.DisplayUtil;
import com.threerings.flex.CommandButton;
import com.threerings.flex.FlexUtil;

import com.threerings.util.Integer;
import com.threerings.util.NamedValueEvent;

import com.threerings.orth.client.OrthContext;
import com.threerings.orth.notify.client.NotificationDisplay;

/**
 * The control bar: the main menu and global UI element across all scenes.
 */
public class ControlBar extends HBox
{
    /**
     * Construct.
     */
    public function ControlBar ()
    {
        Prefs.events.addEventListener(Prefs.PREF_SET, handleConfigValueSet);

        // the rest is in init()
    }

    public function init (top :TopPanel) :void
    {
        styleName = "controlBar";
        verticalScrollPolicy = ScrollPolicy.OFF;
        horizontalScrollPolicy = ScrollPolicy.OFF;
        height = getBarHeight();
        percentWidth = 100;

        // ORTHTODO: Replace this with some other login/logout mechanism?
        // _ctx.getClient().addClientObserver(
        //     new ClientAdapter(null, checkControls, checkControls, null, checkControls, null, null,
        //         checkControls));

        _buttons = new ButtonPalette(top, getBarHeight(), getControlHeight());

        createControls();
        checkControls();
    }

    /**
     * Returns the expected height of the control bar given our current mode. This should normally
     * match the "height" property but is more explicit and valid regardless of display state.
     */
    public function getBarHeight () :int
    {
        return 28;
    }

    /**
     * Returns the expected height for the controls in the bar.
     */
    public function getControlHeight () :int
    {
        const PADDING :int = 3;
        return getBarHeight() - PADDING * 2;
    }

    public function setNotificationDisplay (notificationDisplay :NotificationDisplay) :void
    {
        _notificationDisplay = notificationDisplay;
        setupControls();
        updateUI();
    }

    /**
     * Add a custom component to the control bar.
     * Note that there is no remove: just do component.parent.removeChild(component);
     */
    public function addCustomComponent (comp :UIComponent) :void
    {
        // no priority set- becomes priority = 0.
        addChild(comp);
        sortControls();
    }

    public function addCustomButton (comp :UIComponent, priority :int) :void
    {
        _priorities[comp] = priority;
        _buttons.addButton(comp, priority);
        sortControls();
        _buttons.recheckButtons();
    }

    // from Container
    override public function setActualSize (uw :Number, uh :Number) :void
    {
        super.setActualSize(uw, uh);

        if (_notificationDisplay != null && _notificationDisplay.visible) {
            callLater(_notificationDisplay.sizeDidChange);
        }
    }

    /**
     * Returns either the given component if it is in view, or the expander button that will
     * bring the given component into view when clicked. Returns null if the target is not
     * currently a descendant of the control bar.
     */
    public function getClickableComponent (target :UIComponent) :UIComponent
    {
        if (target.parent == this) {
            return target;
        }
        return _buttons.getClickableComponent(target);
    }

    /**
     * Creates the controls we'll be using. Subclasses would extend this.
     */
    protected function createControls () :void
    {
    }

    protected function createButton (style :String, tipKey :String) :CommandButton
    {
        var cb :CommandButton = new CommandButton();
        cb.styleName = style;
        cb.toolTip = Msgs.GENERAL.get(tipKey);
        return cb;
    }

    /**
     * Checks to see which controls the client should see. Subclasses would extend this.
     */
    protected function checkControls (... ignored) :void
    {
        // if we're already set up, then we're done
        if (numChildren > 0) {
            return;
        }

        // and add our various control buttons
        setupControls();
        updateUI();
    }

    protected function setupControls () :void
    {
        removeAllChildren();
        _buttons.clearButtons();
        _priorities = new Dictionary(true);
        _conditions = new Dictionary(true);
        addControls();
    }

    protected function sortControls () :void
    {
        DisplayUtil.sortDisplayChildren(this, comparePriority);
    }

    protected function addControls () :void
    {
        if (_notificationDisplay != null) {
            addControl(UIComponent(_notificationDisplay), true, NOTIFICATION_SECTION);
        }
    }

    /**
     * Used to sort the buttons.
     */
    protected function comparePriority (comp1 :Object, comp2 :Object) :int
    {
        const pri1 :int = int(_priorities[comp1]);
        const pri2 :int = int(_priorities[comp2]);
        return Integer.compare(pri1, pri2);
    }

    protected function addControl (child :UIComponent, condition :Object, section :int) :void
    {
        addChild(child);
        registerControl(child, condition, section);
    }

    protected function addButton (child :UIComponent, condition :Object, priority :int) :void
    {
        _buttons.addButton(child, priority);
        registerControl(child, condition, priority);
    }

    protected function registerControl (child :UIComponent, condition :Object, priority :int) :void
    {
        _priorities[child] = priority;
        _conditions[child] = condition;
    }

    protected function updateUI () :void
    {
        for (var key :* in _conditions) {
            var condition :Object = _conditions[key];
            if (condition is Function) {
                condition = (condition as Function).call(null);
            }
            FlexUtil.setVisible(UIComponent(key), Boolean(condition));
        }

        sortControls();
        _buttons.recheckButtons();
    }

    protected function handleConfigValueSet (event :NamedValueEvent) :void
    {
    }

    // implicit: custom controls section = 0
    protected static const NOTIFICATION_SECTION :int = 1;

    /** Our clientside context. */
    protected const _ctx :OrthContext = inject(OrthContext);

    /** Button visibility conditions. */
    protected var _conditions :Dictionary = new Dictionary(true);

    /** Button priority levels. */
    protected var _priorities :Dictionary = new Dictionary(true);

    /** Holds the 22x22 button area. */
    protected var _buttons :ButtonPalette;

    /** Displays incoming notifications. */
    protected var _notificationDisplay :NotificationDisplay;
}
}
