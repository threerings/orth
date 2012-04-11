//
// Who - Copyright 2010-2011 Three Rings Design, Inc.

package com.threerings.orth.chat.server;

import java.util.Map;
import java.util.Set;

import com.google.common.base.Preconditions;
import com.google.common.collect.Maps;
import com.google.common.collect.Sets;
import com.google.inject.Inject;
import com.google.inject.Singleton;

import com.samskivert.util.ResultListener;

import com.threerings.util.Resulting;

import com.threerings.presents.client.InvocationService.InvocationListener;
import com.threerings.presents.client.InvocationService;
import com.threerings.presents.data.ClientObject;
import com.threerings.presents.peer.data.NodeObject;
import com.threerings.presents.peer.server.NodeRequestsListener;
import com.threerings.presents.peer.server.PeerManager.NodeRequest;
import com.threerings.presents.peer.server.PeerManager;
import com.threerings.presents.server.ClientManager;
import com.threerings.presents.server.InvocationException;
import com.threerings.presents.server.InvocationManager;

import com.threerings.orth.aether.data.AetherClientObject;
import com.threerings.orth.chat.data.ChannelEntry;
import com.threerings.orth.chat.data.OrthChatCodes;
import com.threerings.orth.chat.data.Speak;
import com.threerings.orth.chat.data.SpeakMarshaller;
import com.threerings.orth.chat.data.SpeakRouter;
import com.threerings.orth.comms.data.CommSender;

@Singleton
public class ChannelManager
{
    public void registerChannel (String id)
    {
        Preconditions.checkState(!_channels.containsKey(id));

        _channels.put(id, new Channel(id));
    }

    public boolean subscribePlayer (AetherClientObject clobj, String channelId)
    {
        Channel channel = Preconditions.checkNotNull(_channels.get(channelId),
            "Unknown channel: " + channelId);
        if (clobj.channels.containsKey(channelId)) {
            return false;
        }
        clobj.addToChannels(new ChannelEntry(channelId, channel.service));
        return true;
    }

    public boolean unsubscribePlayer (AetherClientObject clobj, String channelId)
    {
        if (!clobj.channels.containsKey(channelId)) {
            return false;
        }
        clobj.removeFromChannels(channelId);
        return true;
    }

    protected class Channel implements SpeakProvider
    {
        public ChannelSpeakRouter router;
        public SpeakMarshaller service;

        public Channel (String channelId)
        {
            this.router = new ChannelSpeakRouter(channelId);
            this.service = _invMgr.registerProvider(this, SpeakMarshaller.class);
        }

        @Override public void speak (ClientObject caller, String msg, InvocationListener listener)
            throws InvocationException
        {
            _chatMgr.sendSpeak(this.router, ((AetherClientObject) caller).playerName, msg,
                OrthChatCodes.SPEAK_MSG_TYPE, listener);
        }
    }

    protected class ChannelSpeakRouter implements SpeakRouter
    {
        public ChannelSpeakRouter (String channelId)
        {
            _channelId = channelId;
        }

        @Override public void sendSpeak (Speak speak, ResultListener<Set<Integer>> listener)
        {
            _peerMgr.invokeNodeRequest(
                new ChannelSpeakRequest(_channelId, speak),
                new ChannelSpeakListener(listener));
        }

        protected String _channelId;
    }

    protected static class ChannelSpeakRequest extends NodeRequest
    {
        public ChannelSpeakRequest (String channelId, Speak speak)
        {
            _channelId = channelId;
            _speak = speak;
        }

        @Override public boolean isApplicable (NodeObject nodeobj)
        {
            // hit all the nodes
            return true;
        }

        @Override protected void execute (InvocationService.ResultListener listener)
        {
            Set<Integer> recipients = Sets.newHashSet();
            for (ClientObject clobj : _clientMgr.clientObjects()) {
                if (!(clobj instanceof AetherClientObject)) {
                    continue;
                }
                AetherClientObject plobj = (AetherClientObject) clobj;
                if (plobj.channels.containsKey(_channelId)) {
                    recipients.add(plobj.getPlayerId());
                    CommSender.receiveComm(clobj, _speak);
                }
            }
            listener.requestProcessed(recipients);
        }

        protected String _channelId;
        protected Speak _speak;

        @Inject transient protected ClientManager _clientMgr;
    }

    protected static class ChannelSpeakListener extends Resulting<Set<Integer>>
        implements NodeRequestsListener<Set<Integer>>
    {
        public ChannelSpeakListener (ResultListener<Set<Integer>> chain)
        {
            super(chain);
        }

        @Override public void requestsProcessed (NodeRequestsResult<Set<Integer>> result)
        {
            // merge recipients from all nodes and return
            Set<Integer> allRecipients = Sets.newHashSet();
            for (Set<Integer> nodeRecipients : result.getNodeResults().values()) {
                allRecipients.addAll(nodeRecipients);
            }
            super.requestCompleted(allRecipients);
        }
    }

    protected final Map<String, Channel> _channels = Maps.newHashMap();

    @Inject protected ChatManager _chatMgr;
    @Inject protected InvocationManager _invMgr;
    @Inject protected PeerManager _peerMgr;
}
