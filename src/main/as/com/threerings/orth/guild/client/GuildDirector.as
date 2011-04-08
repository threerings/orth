package com.threerings.orth.guild.client
{
import flashx.funk.ioc.Module;
import flashx.funk.ioc.inject;

import com.threerings.presents.dobj.AttributeChangeListener;
import com.threerings.presents.dobj.AttributeChangedEvent;
import com.threerings.presents.dobj.ChangeListener;
import com.threerings.presents.dobj.DObject;

import com.threerings.orth.aether.data.PlayerObject;
import com.threerings.orth.guild.data.GuildObject;
import com.threerings.orth.nodelet.client.NodeletDirector;

/**
 * Connects to a player's guild on the server and provides convenient entry points and utilities
 * for a player to interact with the guild object.
 */
public class GuildDirector extends NodeletDirector
    implements AttributeChangeListener
{
    /**
     * Creates a new guild director.
     */
    public function GuildDirector()
    {
        // TODO: this is from OrthNodePeerObject, but should also be exposed on the client...
        //       but where?
        super("hostedGuilds");
    }

    /**
     * Called when a player attribute is updated.
     */
    public function attributeChanged (event :AttributeChangedEvent) :void
    {
        if (event.getName() == PlayerObject.GUILD) {
            // connect to the guild
            connect(_plobj.guild);
        }
    }

    // from NodeletDirector
    override protected function refreshPlayer () :void
    {
        if (_plobj != null) {
            _plobj.removeListener(this);
            _plobj = null;
        }

        super.refreshPlayer();

        if (_plobj != null) {
            _plobj.addListener(this);
            connect(_plobj.guild);
        } else {
            disconnect();
        }
    }

    // from NodeletDirector
    override protected function objectAvailable (obj :DObject) :void
    {
        super.objectAvailable(obj);
        _guildObj = GuildObject(obj);
    }

    protected var _guildObj :GuildObject;
    protected var _module :Module = inject(Module);
}
}
