//
// $Id$

package com.threerings.orth.peer.server;

import java.util.Map;

import com.google.common.base.Function;
import com.google.common.base.Preconditions;
import com.google.common.collect.Iterables;
import com.google.common.collect.Maps;

import com.samskivert.util.Lifecycle;
import com.samskivert.util.ObserverList;
import com.threerings.presents.data.ClientObject;
import com.threerings.presents.peer.data.ClientInfo;
import com.threerings.presents.peer.data.NodeObject;
import com.threerings.presents.peer.server.PeerNode;
import com.threerings.presents.peer.server.PeerManager;
import com.threerings.presents.server.PresentsSession;

import com.threerings.orth.aether.data.AetherAuthName;
import com.threerings.orth.aether.data.PlayerObject;
import com.threerings.orth.data.AuthName;
import com.threerings.orth.data.OrthName;
import com.threerings.orth.nodelet.data.HostedNodelet;
import com.threerings.orth.nodelet.data.Nodelet;
import com.threerings.orth.nodelet.server.NodeletRegistry;
import com.threerings.orth.peer.data.OrthClientInfo;
import com.threerings.orth.peer.data.OrthNodeObject;
import com.threerings.orth.room.data.RoomLocus;

/**
 * Extends CrowdPeerManager with functionality needed for Orth and its intended uses.
 */
public abstract class OrthPeerManager extends PeerManager
{
    /** The maximum number of nodes we can start up after a global reboot. */
    public static final int MAX_NODES = 100;

    /** Our {@link PeerObserver}s. */
    public final ObserverList<PeerObserver> peerObs = ObserverList.newFastUnsafe();

    /**
     * Register the observation of sessions identified by a new {@link AuthName} subclass
     * and return the associated {@link ObserverList}. Observers will be notified of loggings
     * in an d out of any clients identified by the given class.
     */
    public <O extends OrthName> ObserverList<FarSeeingObserver<O>> observe (Class<?> type)
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
     * Returns the node name of the peer that is hosting the specified nodelet, or null if no peer
     * has published that they are hosting it.
     */
    public HostedNodelet findHostedNodelet (final String dsetName, final Nodelet nodelet)
    {
        return findHostedNodelet(dsetName, nodelet.getId());
    }

    /**
     * Returns the node name of the peer that is hosting the nodelet with the specified id, or null
     * if no peer has published that they are hosting it.
     */
    public HostedNodelet findHostedNodelet (final String dsetName, final int nodeletId)
    {
        return lookupNodeDatum(new Function<NodeObject, HostedNodelet>() {
            public HostedNodelet apply (NodeObject nodeobj) {
                return ((OrthNodeObject) nodeobj)
                    .<HostedNodelet>getSet(dsetName).get(nodeletId);
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
    public void addRegistry (String dsetName, NodeletRegistry registry)
    {
        Preconditions.checkArgument(!_nodeletRegistries.containsKey(dsetName),
            "duplicate registries");
        _nodeletRegistries.put(dsetName, registry);
    }

    /**
     * Retrieves the registry for the dset of the given name. This allows registries to be
     * obtained generically when the concrete type is not known or the instance cannot be injected.
     */
    public NodeletRegistry getRegistry (String dsetName)
    {
        return _nodeletRegistries.get(dsetName);
    }

    /**
     * Return a uniquely assigned integer for this node, smaller than {@link MAX_NODES}.
     */
    public abstract int getNodeId ();

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

    @Override // from CrowdPeerManager
    protected void initClientInfo (PresentsSession client, ClientInfo info)
    {
        super.initClientInfo(client, info);

        ClientObject clobj = client.getClientObject();
        if (clobj instanceof PlayerObject) {
            ((OrthClientInfo)info).playerName = ((PlayerObject) clobj).playerName;
        }

        loggedOn(_nodeName, (OrthClientInfo) info);
    }

    @Override // from PeerManager
    protected Class<? extends PeerNode> getPeerNodeClass ()
    {
        return OrthPeerNode.class;
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
    protected  <T extends OrthName> void loggedOn (final String nodeName, OrthClientInfo info)
    {
        apply(info, new VizOp<T>() {
            public void apply (FarSeeingObserver<T> observer, T name) {
                observer.loggedOn(nodeName, name);
            }
        });
    }

    /** Call the 'loggedOff' method on this client's registered {@link FarSeeingObserver} list. */
    protected <T extends OrthName> void loggedOff (final String nodeName, OrthClientInfo info)
    {
        apply(info, new VizOp<T>() {
            public void apply (FarSeeingObserver<T> observer, T name) {
                observer.loggedOff(nodeName, name);
            }
        });
    }

    protected <T extends OrthName> void apply (OrthClientInfo info, VizOp<T> op)
    {
        @SuppressWarnings("unchecked")
        Observation<T> observation = (Observation<T>) _observations.get(info.username.getClass());
        if (observation != null) {
            observation.apply(info, op);
        }
    }

    protected <T extends OrthName> Observation<T> newObservation (Class<?> type)
    {
        if (_observations.containsKey(type)) {
            throw new IllegalStateException("Multiple observations on type: " + type);
        }
        Observation<T> observation = new Observation<T>();
        _observations.put(type, observation);
        return observation;
    }

    protected interface VizOp<T extends OrthName>
    {
        void apply (FarSeeingObserver<T> observer, T name);
    }

    protected static class Observation<T extends OrthName>
    {
        public void apply (final OrthClientInfo info, final VizOp<T> op)
        {
            _list.apply(new ObserverList.ObserverOp<FarSeeingObserver<T>>() {
                public boolean apply (FarSeeingObserver<T> observer) {
                    @SuppressWarnings("unchecked")
                    T vizName = (T) info.playerName;
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
    public static interface FarSeeingObserver<T extends OrthName>
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

    protected Map<String, NodeletRegistry> _nodeletRegistries = Maps.newHashMap();

    protected final Map<Class<?>, Observation<?>> _observations = Maps.newHashMap();
}
