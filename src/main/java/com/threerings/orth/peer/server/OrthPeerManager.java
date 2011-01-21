//
// $Id: $


package com.threerings.orth.peer.server;

import java.util.Map;

import com.google.common.collect.Maps;

import com.samskivert.util.Lifecycle;
import com.samskivert.util.ObserverList;

import com.threerings.crowd.peer.server.CrowdPeerManager;
import com.threerings.presents.peer.data.ClientInfo;
import com.threerings.presents.peer.data.NodeObject;
import com.threerings.presents.peer.server.PeerNode;
import com.threerings.presents.server.PresentsSession;

import com.threerings.orth.data.AuthName;
import com.threerings.orth.data.OrthName;
import com.threerings.orth.peer.data.OrthClientInfo;
import com.threerings.orth.peer.data.OrthNodeObject;

/**
 *
 */
public abstract class OrthPeerManager extends CrowdPeerManager
{
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

    @Override // from CrowdPeerManager
    protected NodeObject createNodeObject ()
    {
        return (_onobj = new OrthNodeObject());
    }


    @Override // from CrowdPeerManager
    protected ClientInfo createClientInfo ()
    {
        return new OrthClientInfo();
    }

    @Override // from CrowdPeerManager
    protected void initClientInfo (PresentsSession client, ClientInfo info)
    {
        super.initClientInfo(client, info);

        loggedOn((OrthClientInfo) info);
    }

    @Override // from PeerManager
    protected void clearClientInfo (PresentsSession client, ClientInfo info)
    {
        super.clearClientInfo(client, info);

        loggedOff((OrthClientInfo)info);
    }

    @Override // from PeerManager
    protected void clientLoggedOn (String nodeName, ClientInfo clinfo)
    {
        super.clientLoggedOn(nodeName, clinfo);

        loggedOn((OrthClientInfo)clinfo);
    }

    @Override // from PeerManager
    protected void clientLoggedOff (String nodeName, ClientInfo clinfo)
    {
        super.clientLoggedOff(nodeName, clinfo);

        loggedOff( (OrthClientInfo)clinfo);
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
    protected  <T extends OrthName> void loggedOn (OrthClientInfo info)
    {
        apply(info, new VizOp<T>() {
            public void apply (FarSeeingObserver<T> observer, T name) {
                observer.loggedOn(_nodeName, name);
            }
        });
    }

    /** Call the 'loggedOff' method on this client's registered {@link FarSeeingObserver} list. */
    protected <T extends OrthName> void loggedOff (OrthClientInfo info)
    {
        apply(info, new VizOp<T>() {
            public void apply (FarSeeingObserver<T> observer, T name) {
                observer.loggedOff(_nodeName, name);
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
                    T vizName = (T) info.visibleName;
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
         * Notifies the observer when a member has logged onto an msoy server.
         */
        void loggedOn (String node, T member);

        /**
         * Notifies the observer when a member has logged off of an msoy server.
         */
        void loggedOff (String peerName, T member);
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

    protected final Map<Class<?>, Observation<?>> _observations = Maps.newHashMap();
}
