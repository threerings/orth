//
// Who - Copyright 2010-2011 Three Rings Design, Inc.

package com.threerings.orth.aether.server;

import com.google.inject.Inject;
import com.google.inject.Singleton;

import com.threerings.util.Name;

import com.threerings.orth.aether.data.AetherAuthName;
import com.threerings.orth.aether.data.PeeredPlayerInfo;
import com.threerings.orth.data.AuthName;
import com.threerings.orth.data.where.Whereabouts;
import com.threerings.orth.locus.data.LocusAuthName;
import com.threerings.orth.peer.data.OrthClientInfo;
import com.threerings.orth.peer.server.OrthPeerManager.FarSeeingObserver;
import com.threerings.orth.peer.server.OrthPeerManager;

import com.threerings.signals.Signal1;
import com.threerings.signals.Signals;

@Singleton
public class PeerEyeballer
{
    public final Signal1<PeeredPlayerInfo> playerLoggedOn = Signals.newSignal1();
    public final Signal1<AetherAuthName> playerLoggedOff = Signals.newSignal1();
    public final Signal1<PeeredPlayerInfo> playerInfoChanged = Signals.newSignal1();

    @Inject public PeerEyeballer (OrthPeerManager peerMgr)
    {
        peerMgr.farSeeingObs.add(new FarSeeingObserver() {
            @Override public void loggedOn (String node, OrthClientInfo info) {
                if (info.username instanceof AetherAuthName) {
                    playerLoggedOn.dispatch(getPlayerData(info));
                }
            }
            @Override public void loggedOff (String node, Name username) {
                if (username instanceof AetherAuthName) {
                    playerLoggedOff.dispatch((AetherAuthName) username);
                }
            }
            @Override public void infoChanged (String node, OrthClientInfo info) {
                PeeredPlayerInfo result = null;
                if (info.username instanceof AetherAuthName) {
                    result = getPlayerData(info);

                } else if (info.username instanceof LocusAuthName) {
                    result = getPlayerData(((AuthName) info.username).getId(), null, info);
                }
                if (result != null) {
                    playerInfoChanged.dispatch(result);
                } // else player logged out
            }
        });
    }

    public PeeredPlayerInfo getPlayerData (int playerId)
    {
        return getPlayerData(playerId, null, null);
    }

    protected PeeredPlayerInfo getPlayerData (OrthClientInfo aetherInfo)
    {
        return getPlayerData(aetherInfo.visibleName.getId(), aetherInfo, null);
    }

    protected PeeredPlayerInfo getPlayerData (int playerId,
        OrthClientInfo aetherInfo, OrthClientInfo locusInfo)
    {
        if (aetherInfo == null) {
            aetherInfo = _peerMgr.locatePlayer(playerId);
            if (aetherInfo == null) {
                return null;
            }
        }
        if (locusInfo == null) {
            locusInfo = _peerMgr.locateLocusBody(playerId);
        }

        PeeredPlayerInfo data = createPlayerData();
        populatePlayerData(data, aetherInfo, locusInfo);
        return data;
    }

    protected PeeredPlayerInfo createPlayerData ()
    {
        return new PeeredPlayerInfo();
    }

    protected void populatePlayerData (
        PeeredPlayerInfo data, OrthClientInfo aetherInfo, OrthClientInfo locusInfo)
    {
        data.authName = (AetherAuthName) aetherInfo.username;
        data.visibleName = aetherInfo.visibleName;
        data.whereabouts = figureWhereabouts(aetherInfo, locusInfo);
    }

    protected Whereabouts figureWhereabouts (OrthClientInfo aetherInfo, OrthClientInfo locusInfo)
    {
        if (locusInfo == null || locusInfo.whereabouts == null) {
            return Whereabouts.ONLINE;
        }
        return locusInfo.whereabouts;
    }

    @Inject OrthPeerManager _peerMgr;
}
