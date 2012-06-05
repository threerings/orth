//
// Orth - a package of MMO services: rooms, parties, guilds, and more!
// Copyright 2010-2012 Three Rings Design, Inc.

package com.threerings.orth.peer.server;

import java.util.Map;
import java.util.Set;

import com.google.common.base.Function;
import com.google.common.base.Preconditions;
import com.google.common.collect.Iterables;
import com.google.common.collect.Maps;
import com.google.common.collect.Sets;

import com.samskivert.util.Lifecycle;
import com.samskivert.util.ObserverList.ObserverOp;
import com.samskivert.util.ObserverList;
import com.samskivert.util.ResultListener;

import com.threerings.util.Name;
import com.threerings.util.Resulting;

import com.threerings.presents.data.ClientObject;
import com.threerings.presents.data.InvocationCodes;
import com.threerings.presents.peer.data.ClientInfo;
import com.threerings.presents.peer.data.NodeObject;
import com.threerings.presents.peer.server.PeerManager;
import com.threerings.presents.peer.server.PeerNode;
import com.threerings.presents.server.InvocationException;
import com.threerings.presents.server.PresentsSession;

import com.threerings.orth.aether.data.AetherAuthName;
import com.threerings.orth.aether.data.AetherClientObject;
import com.threerings.orth.data.AuthName;
import com.threerings.orth.data.PlayerName;
import com.threerings.orth.data.where.Whereabouts;
import com.threerings.orth.locus.data.LocusAuthName;
import com.threerings.orth.nodelet.data.HostedNodelet;
import com.threerings.orth.nodelet.data.Nodelet;
import com.threerings.orth.nodelet.server.NodeletRegistry;
import com.threerings.orth.peer.data.OrthClientInfo;
import com.threerings.orth.peer.data.OrthNodeObject;
import com.threerings.orth.room.data.RoomAuthName;
import com.threerings.orth.room.data.RoomLocus;

import static com.threerings.orth.Log.log;

/**
 * Extends PeerManager with functionality needed for Orth and its intended uses.
 */
public abstract class OrthPeerManager extends PeerManager
{
    /** Our {@link PeerObserver}s. */
    public final ObserverList<PeerObserver> peerObs = ObserverList.newFastUnsafe();

    /** Our {@link FarSeeingObserver}s. */
    public final ObserverList<FarSeeingObserver> farSeeingObs = ObserverList.newFastUnsafe();

    /**
     * Used to notify interested parties when clients log onto and off of servers. This includes
     * peer servers and this local server, therefore all client activity anywhere may be tracked
     * through this interface.
     */
    public static interface FarSeeingObserver
    {
        /**
         * Notifies the observer when a client has logged onto an orth server.
         */
        void loggedOn (String node, OrthClientInfo info);

        /**
         * Notifies the observer when a client has logged off of an orth server.
         */
        void loggedOff (String node, Name client);

        /**
         * Notifies the observer when a client's info has changed.
         */
        void infoChanged (String node, OrthClientInfo info);
    }

    /**
     * Used to hear when peers connect or disconnect from this node.
     */
    public static interface PeerObserver
    {
        /** Called when a peer logs onto this node. */
        void connectedToPeer (OrthNodeObject nodeobj);

        /** Called when a peer logs off of this node. */
        void disconnectedFromPeer (String node);
    }

    public OrthPeerManager (Lifecycle cycle)
    {
        super(cycle);
    }

    /**
     * Return a reference to our {@link OrthNodeObject}.
     */
    public OrthNodeObject getOrthNodeObject ()
    {
        return _onobj;
    }

    /**
     * Returns an iterable over all node objects (this and other peers') casted to {@link
     * OrthNodeObject}.
     */
    public Iterable<OrthNodeObject> getOrthNodeObjects ()
    {
        return Iterables.transform(getNodeObjects(), new Function<NodeObject, OrthNodeObject>() {
            public OrthNodeObject apply (NodeObject node) {
                return (OrthNodeObject) node;
            }
        });
    }

    /**
     * Returns the node name of the peer that is hosting the nodelet with the specified id, or null
     * if no peer has published that they are hosting it.
     */
    public HostedNodelet findHostedNodelet (final String dsetName, Nodelet nodelet)
    {
        final Comparable<?> key = nodelet.getKey();
        return lookupNodeDatum(new Function<NodeObject, HostedNodelet>() {
            public HostedNodelet apply (NodeObject nodeobj) {
                return nodeobj.<HostedNodelet>getSet(dsetName).get(key);
            }
        });
    }

    /**
     * Returns the node name of the peer that is hosting the specified room, or null if no peer
     * has published that they are hosting the place.
     */
    public HostedNodelet findHostedRoom (RoomLocus locus)
    {
        return findHostedNodelet(OrthNodeObject.HOSTED_ROOMS, locus);
    }

    /**
     * Locate an aether client by player id.
     */
    public OrthClientInfo locatePlayer (int playerId)
    {
        return (OrthClientInfo)locateClient(AetherAuthName.makeKey(playerId));
    }

    /**
     * Locates the ignore list for one player and tests to see if another player is on it.
     */
    public boolean isIgnoring (int ignorerId, int ignoreeId)
    {
        OrthClientInfo info = locatePlayer(ignorerId);
        return (info != null) && info.ignoring.contains(ignoreeId);
    }

    /**
     * Locate an aether client by player id.
     */
    public OrthClientInfo locateLocusBody (int playerId)
    {
        Set<LocusAuthName> keys = Sets.newHashSet();
        addLocusKeys(keys, playerId);
        for (LocusAuthName key : keys) {
            OrthClientInfo info = (OrthClientInfo) locateClient(key);
            if (info != null) {
                return info;
            }
        }
        return null;
    }

    /**
     * Adds the registry of the specified name to the this peer. This is called by the
     * {@code NodeletRegistry} constructor. It is an error to add more than one registry with the
     * same name.
     */
    public void addRegistry (Class<? extends Nodelet> nodeletClass, NodeletRegistry registry)
    {
        Preconditions.checkArgument(!_nodeletRegistries.containsKey(nodeletClass),
            "duplicate registries");
        _nodeletRegistries.put(nodeletClass, registry);
    }

    /**
     * Retrieves the registry for the dset of the given name. This allows registries to be
     * obtained generically when the concrete type is not known or the instance cannot be injected.
     */
    public NodeletRegistry getRegistry (Class<? extends Nodelet> nodeletClass)
    {
        return _nodeletRegistries.get(nodeletClass);
    }

    /**
     * Invokes the given request on exactly one node, failing if none or more than one is found.
     */
    public <T> void invokeSingleNodeRequest (NodeRequest request, ResultListener<T> lner)
    {
        Set<String> nodes = findApplicableNodes(request);
        if (nodes.size() == 1) {
            invokeNodeRequest(Iterables.getOnlyElement(nodes), request,
                new Resulting<T>(lner));
        } else if (nodes.isEmpty()) {
            lner.requestFailed(new Exception("e.player_not_found"));
        } else {
            lner.requestFailed(new Exception("e.internal_error"));
            log.warning("Player request target is on multiple nodes, dropping",
                "request", request, "nodes", nodes);
        }
    }

    /**
     * Invokes the given action on exactly one node.
     *
     * @throws InvocationException if zero or more than one applicable node is found.
     */
    public <T> void invokeSingleNodeAction (NodeAction action) throws InvocationException
    {
        Set<String> nodes = findApplicableNodes(action);
        if (nodes.size() == 1) {
            invokeNodeAction(Iterables.getOnlyElement(nodes), action);
            return;
        } else if (nodes.isEmpty()) {
            log.warning("Action target not found", "action", action, "nodes", nodes);
        } else {
            log.warning("Action target on multiple nodes", "action", action, "nodes", nodes);
        }
        throw new InvocationException(InvocationCodes.E_INTERNAL_ERROR);
    }

    public Whereabouts getWhereabouts (int playerId)
    {
        OrthClientInfo aetherInfo = locatePlayer(playerId);
        // we may not be logged in at all
        if (aetherInfo == null) {
            return Whereabouts.OFFLINE;
        }
        OrthClientInfo locusInfo = locateLocusBody(playerId);
        // else if we have a locus connection, that is authoritative
        return ((locusInfo != null) ? locusInfo : aetherInfo).whereabouts;
    }

    public void updateWhereabouts (AuthName name)
    {
        updateWhereabouts(name, Whereabouts.ONLINE);
    }

    public void updateWhereabouts (AuthName name, Whereabouts whereabouts)
    {
        OrthClientInfo info = (OrthClientInfo) _nodeobj.clients.get(name);
        if (info != null) {
            info.whereabouts = whereabouts;
            updateClientInfo(info);
        }
    }

    /**
     * Add or remove someone from a player's peer-wide ignore list information.
     */
    public boolean noteIgnoring (int ignorerId, int ignoreeId, boolean doAdd)
    {
        OrthClientInfo info = (OrthClientInfo) _nodeobj.clients.get(ignorerId);
        if (info != null) {
            int setSize = info.ignoring.size();
            if (doAdd) {
                info.ignoring.add(ignoreeId);
            } else {
                info.ignoring.remove(ignoreeId);
            }
            if (setSize != info.ignoring.size()) {
                updateClientInfo(info);
                return true;
            }
        }
        return false;
    }


    protected void updateClientInfo (OrthClientInfo info)
    {
        _nodeobj.updateClients(info);
        clientInfoChanged(_nodeName, info);
    }

    @Override // from PeerManager
    protected NodeObject createNodeObject ()
    {
        return (_onobj = new OrthNodeObject());
    }

    @Override // from PeerManager
    protected ClientInfo createClientInfo ()
    {
        return new OrthClientInfo();
    }

    @Override // from PeerManager
    protected void initClientInfo (PresentsSession client, ClientInfo info)
    {
        super.initClientInfo(client, info);

        OrthClientInfo orthInfo = (OrthClientInfo) info;

        ClientObject clobj = client.getClientObject();
        if (clobj.username instanceof AetherAuthName) {
            AetherClientObject aetherObj = (AetherClientObject) clobj;
            orthInfo.visibleName = aetherObj.playerName;
            orthInfo.guild = aetherObj.guildName;
            orthInfo.ignoring = Sets.newHashSet(
                Iterables.transform(aetherObj.ignoring.asSet(), PlayerName.ID));
        }
        orthInfo.whereabouts = Whereabouts.ONLINE;

        loggedOn(_nodeName, orthInfo);
    }

    @Override // from PeerManager
    protected void clearClientInfo (PresentsSession client, ClientInfo info)
    {
        super.clearClientInfo(client, info);

        loggedOff(_nodeName, (OrthClientInfo) info);
    }

    @Override // from PeerManager
    protected Class<? extends PeerNode> getPeerNodeClass ()
    {
        return OrthPeerNode.class;
    }

    /**
     * This method should create a {@link LocusAuthName} instance for every Locus type known
     * in the system. This is our poor man's approach to locating locus bodies. A more complex
     * system could easily be imagined, but this one works well enough for now. Subclasses
     * must extend this method.
     */
    protected void addLocusKeys (Set<LocusAuthName> keys, int playerId)
    {
        keys.add(RoomAuthName.makeKey(playerId));
    }

    @Override // from PeerManager
    protected void clientLoggedOn (String nodeName, ClientInfo clinfo)
    {
        super.clientLoggedOn(nodeName, clinfo);

        loggedOn(nodeName, (OrthClientInfo) clinfo);
    }

    @Override // from PeerManager
    protected void clientLoggedOff (String nodeName, ClientInfo clinfo)
    {
        super.clientLoggedOff(nodeName, clinfo);

        loggedOff(nodeName, (OrthClientInfo) clinfo);
    }

    protected void clientInfoChanged (String nodeName, OrthClientInfo clinfo)
    {
        infoChanged(nodeName, clinfo);
    }

    @Override // from PeerManager
    protected void connectedToPeer (PeerNode peer)
    {
        super.connectedToPeer(peer);

        // notify our peer observers
        final OrthNodeObject nodeobj = (OrthNodeObject)peer.nodeobj;
        peerObs.apply(new ObserverList.ObserverOp<PeerObserver>() {
            public boolean apply (PeerObserver observer) {
                observer.connectedToPeer(nodeobj);
                return true;
            }
        });
    }

    @Override // from PeerManager
    protected void disconnectedFromPeer (PeerNode peer)
    {
        super.disconnectedFromPeer(peer);

        // notify our peer observers
        final String nodeName = peer.nodeobj.nodeName;
        peerObs.apply(new ObserverList.ObserverOp<PeerObserver>() {
            public boolean apply (PeerObserver observer) {
                observer.disconnectedFromPeer(nodeName);
                return true;
            }
        });
    }

    /** Call the 'loggedOn' method on this client's registered {@link FarSeeingObserver} list. */
    protected void loggedOn (final String nodeName, final OrthClientInfo info)
    {
        farSeeingObs.apply(new ObserverOp<FarSeeingObserver>() {
            @Override public boolean apply (FarSeeingObserver observer) {
                observer.loggedOn(nodeName, info);
                return true;
            }
        });
    }

    /** Call the 'loggedOff' method on this client's registered {@link FarSeeingObserver} list. */
    protected void loggedOff (final String nodeName, final OrthClientInfo info)
    {
        farSeeingObs.apply(new ObserverOp<FarSeeingObserver>() {
            @Override public boolean apply (FarSeeingObserver observer) {
                observer.loggedOff(nodeName, info.username);
                return true;
            }
        });
    }

    /** Call the 'infoChanged' method on this client's registered {@link FarSeeingObserver} list. */
    protected void infoChanged (final String nodeName, final OrthClientInfo info)
    {
        farSeeingObs.apply(new ObserverOp<FarSeeingObserver>()
        {
            @Override public boolean apply (FarSeeingObserver observer)
            {
                observer.infoChanged(nodeName, info);
                return true;
            }
        });
    }

    protected OrthNodeObject _onobj;

    protected Map<Class<? extends Nodelet>, NodeletRegistry> _nodeletRegistries = Maps.newHashMap();
}
