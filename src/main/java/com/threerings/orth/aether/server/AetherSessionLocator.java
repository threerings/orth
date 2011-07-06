//
// Orth - a package of MMO services: rooms, parties, guilds, and more!
// Copyright 2010-2011 Three Rings Design, Inc.

package com.threerings.orth.aether.server;

import java.util.List;

import com.google.common.collect.Lists;
import com.google.inject.Inject;
import com.google.inject.Singleton;

import com.samskivert.util.Lifecycle;

import com.threerings.presents.annotation.EventThread;
import com.threerings.presents.data.ClientObject;
import com.threerings.presents.server.ClientManager;
import com.threerings.presents.server.PresentsSession;

import com.threerings.orth.aether.data.AetherAuthName;
import com.threerings.orth.aether.data.AetherClientObject;

/**
 * Convenience class for finding {@link PresentsSession} instances logged into this aether server.
 */
@Singleton @EventThread
public class AetherSessionLocator implements Lifecycle.InitComponent
{
    public interface Observer
    {
        void playerLoggedIn (PresentsSession session, AetherClientObject plobj);
        void playerWillLogout (PresentsSession session, AetherClientObject plobj);
    }

    @Inject public AetherSessionLocator (Lifecycle lifecycle)
    {
        lifecycle.addComponent(this);
    }

    public void init ()
    {
        _clientMgr.addClientObserver(new ClientManager.DetailedClientObserver() {
            @Override public void clientSessionDidStart (PresentsSession session) {
                AetherClientObject plobj = player(session);
                if (plobj != null) {
                    for (Observer o : _observers) {
                        try {
                            o.playerLoggedIn(session, plobj);
                        } catch (Exception e) {

                        }
                    }
                }
            }

            @Override public void clientSessionWillEnd (PresentsSession session) {
                AetherClientObject plobj = player(session);
                if (plobj != null) {
                    for (Observer o : _observers) {
                        try {
                            o.playerWillLogout(session, plobj);
                        } catch (Exception e) {

                        }
                    }
                }
            }

            @Override public void clientSessionDidEnd (PresentsSession session) {
            }

            AetherClientObject player (PresentsSession session) {
                ClientObject clobj = session.getClientObject();
                if (clobj instanceof AetherClientObject) {
                    return (AetherClientObject)clobj;
                }
                return null;
            }
        });
    }

    public void addObserver (Observer observer)
    {
        _observers.add(observer);
    }

    public void removeObserver (Observer observer)
    {
        _observers.remove(observer);
    }

    public AetherClientObject lookupPlayer (int playerId)
    {
        return forClient(_clientMgr.getClientObject(AetherAuthName.makeKey(playerId)));
    }

    public AetherClientObject forClient (ClientObject client)
    {
        return (AetherClientObject) client;
    }

    /** Other code interested in players logging on and off. */
    protected List<Observer> _observers = Lists.newArrayList();

    // dependencies
    @Inject protected ClientManager _clientMgr;
}
