//
// Orth - a package of MMO services: rooms, parties, guilds, and more!
// Copyright 2010-2011 Three Rings Design, Inc.

package com.threerings.orth.peer.server;

import java.util.Map;
import java.util.Set;

import com.google.common.base.Function;
import com.google.common.base.Preconditions;
import com.google.common.collect.Iterables;
import com.google.common.collect.Maps;

import com.samskivert.util.Lifecycle;
import com.samskivert.util.ObserverList;
import com.samskivert.util.ResultListener;

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
import com.threerings.orth.nodelet.data.HostedNodelet;
import com.threerings.orth.nodelet.data.Nodelet;
import com.threerings.orth.nodelet.server.NodeletRegistry;
import com.threerings.orth.peer.data.OrthClientInfo;
import com.threerings.orth.peer.data.OrthNodeObject;
import com.threerings.orth.room.data.RoomLocus;

import static com.threerings.orth.Log.log;

/**
 * Extends PeerManager with functionality needed for Orth and its intended uses.
 */
public abstract class OrthPeerManager extends PeerManager
{
    /** Our {@link PeerObserver}s. */
    public final ObserverList<PeerObserver> peerObs = ObserverList.newFastUnsafe();

    /**
     * Register the observation of sessions identified by a new {@link AuthName} subclass
     * and return the associated {@link ObserverList}. Observers will be notified of loggings
     * in an d out of any clients identified by the given class.
     */
    public <O extends PlayerName> ObserverList<FarSeeingObserver<O>> observe (Class<?> type)
    {
        return this.<O>newObservation(type).getList();
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
                return (OrthNodeObject)node;
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
     * Locate a client by player id.
     */
    public OrthClientInfo locatePlayer (int playerId)
    {
        return (OrthClientInfo)locateClient(AetherAuthName.makeKey(playerId));
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

        ClientObject clobj = client.getClientObject();
        if (clobj instanceof AetherClientObject) {
            ((OrthClientInfo)info).orthName = ((AetherClientObject) clobj).playerName;
        }

        loggedOn(_nodeName, (OrthClientInfo) info);
    }

    @Override // from PeerManager
    protected void clearClientInfo (PresentsSession client, ClientInfo info)
    {
        super.clearClientInfo(client, info);

        loggedOff(_nodeName, (OrthClientInfo)info);
    }

    @Override // from PeerManager
    protected void clientLoggedOn (String nodeName, ClientInfo clinfo)
    {
        super.clientLoggedOn(nodeName, clinfo);

        loggedOn(nodeName, (OrthClientInfo)clinfo);
    }

    @Override // from PeerManager
    protected void clientLoggedOff (String nodeName, ClientInfo clinfo)
    {
        super.clientLoggedOff(nodeName, clinfo);

        loggedOff(nodeName, (OrthClientInfo)clinfo);
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
    protected  <T extends PlayerName> void loggedOn (final String nodeName, OrthClientInfo info)
    {
        apply(info, new VizOp<T>() {
            public void apply (FarSeeingObserver<T> observer, T name) {
                observer.loggedOn(nodeName, name);
            }
        });
    }

    /** Call the 'loggedOff' method on this client's registered {@link FarSeeingObserver} list. */
    protected <T extends PlayerName> void loggedOff (final String nodeName, OrthClientInfo info)
    {
        apply(info, new VizOp<T>() {
            public void apply (FarSeeingObserver<T> observer, T name) {
                observer.loggedOff(nodeName, name);
            }
        });
    }

    protected <T extends PlayerName> void apply (OrthClientInfo info, VizOp<T> op)
    {
        @SuppressWarnings("unchecked")
        Observation<T> observation = (Observation<T>) _observations.get(info.username.getClass());
        if (observation != null) {
            observation.apply(info, op);
        }
    }

    protected <T extends PlayerName> Observation<T> newObservation (Class<?> type)
    {
        if (_observations.containsKey(type)) {
            throw new IllegalStateException("Multiple observations on type: " + type);
        }
        Observation<T> observation = new Observation<T>();
        _observations.put(type, observation);
        return observation;
    }

    protected interface VizOp<T extends PlayerName>
    {
        void apply (FarSeeingObserver<T> observer, T name);
    }

    protected static class Observation<T extends PlayerName>
    {
        public void apply (final OrthClientInfo info, final VizOp<T> op)
        {
            _list.apply(new ObserverList.ObserverOp<FarSeeingObserver<T>>() {
                public boolean apply (FarSeeingObserver<T> observer) {
                    @SuppressWarnings("unchecked")
                    T vizName = (T) info.orthName;
                    op.apply(observer, vizName);
                    return true;
                }
            });
        }

        public ObserverList<FarSeeingObserver<T>> getList()
        {
            return _list;
        }

        protected ObserverList<FarSeeingObserver<T>> _list = ObserverList.newFastUnsafe();

    }

    /**
     * Used to notify interested parties when clients log onto and off of servers. This includes
     * peer servers and this local server, therefore all client activity anywhere may be tracked
     * through this interface.
     */
    public static interface FarSeeingObserver<T extends PlayerName>
    {
        /**
         * Notifies the observer when a member has logged onto an orth server.
         */
        void loggedOn (String node, T member);

        /**
         * Notifies the observer when a member has logged off of an orth server.
         */
        void loggedOff (String node, T member);
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

    protected OrthNodeObject _onobj;

    protected Map<Class<? extends Nodelet>, NodeletRegistry> _nodeletRegistries = Maps.newHashMap();

    protected final Map<Class<?>, Observation<?>> _observations = Maps.newHashMap();
}
