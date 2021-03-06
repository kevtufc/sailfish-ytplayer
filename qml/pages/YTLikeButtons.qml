/*-
 * Copyright (c) 2014 Peter Tworek
 * All rights reserved.
 *
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions
 * are met:
 * 1. Redistributions of source code must retain the above copyright
 * notice, this list of conditions and the following disclaimer.
 * 2. Redistributions in binary form must reproduce the above copyright
 * notice, this list of conditions and the following disclaimer in the
 * documentation and/or other materials provided with the distribution.
 * 3. Neither the name of the author nor the names of any co-contributors
 * may be used to endorse or promote products derived from this software
 * without specific prior written permission.
 *
 * THIS SOFTWARE IS PROVIDED BY THE AUTHOR AND CONTRIBUTORS ``AS IS'' AND
 * ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
 * IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
 * ARE DISCLAIMED. IN NO EVENT SHALL THE AUTHOR OR CONTRIBUTORS BE LIABLE
 * FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
 * DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS
 * OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION)
 * HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT
 * LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY
 * OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF
 * SUCH DAMAGE.
 */

import QtQuick 2.0
import Sailfish.Silica 1.0
import "YoutubeClientV3.js" as Yt


Row {
    id: root

    property bool enabled: false
    property bool dataValid: false
    property string videoId: ""

    property alias dislikes: dislikeCount.text
    property alias likes: likeCount.text

    function updateState() {
        var ranking
        if (likeButton.selected) {
            ranking = Yt.VIDEO_RANKING_LIKE
        } else if (dislikeButton.selected) {
            ranking = Yt.VIDEO_RANKING_DISLIKE
        } else {
            ranking = Yt.VIDEO_RANKING_NONE
        }
        Log.info("Video ranking changed: " + ranking)

        Yt.rankVideo(videoId, ranking, function() {
            Log.debug("Video rank changed succesfully")
        }, function (error) {
            errorNotification.show(error)
        })
    }

    function refresh() {
        if (root.enabled && dataValid) {
            Yt.isVideoLiked(videoId, function (response) {
                Log.debug("Video ranking status: " + response.rating)
                if (response.rating === Yt.VIDEO_RANKING_DISLIKE) {
                    dislikeButton.selected = true
                } else if (response.rating === Yt.VIDEO_RANKING_LIKE) {
                    likeButton.selected = true
                }
            }, function (error) {
                errorNotification.show(error)
            })
        } else if (!root.enabled) {
            likeButton.selected = false
            dislikeButton.selected = false
        }
    }

    onDataValidChanged: refresh()
    onEnabledChanged: refresh()

    MouseArea {
        id: likeButton
        width: parent.width / 2
        height: likeIcon.height
        enabled: root.enabled

        property bool selected: false
        property color activeColor: selected ? "#AA00AA00" : "transparent"

        onSelectedChanged: {
            if (selected) {
                likeCount.text = parseInt(likeCount.text) + 1
            } else {
                likeCount.text = parseInt(likeCount.text) - 1
            }
        }

        Rectangle {
            id: likeBackground
            anchors.fill: parent
            color: parent.pressed ? Theme.secondaryHighlightColor : parent.activeColor
        }
        Image {
            property color hcolor: parent.pressed ? Theme.highlightColor : Theme.primaryColor
            id: likeIcon
            source: "image://theme/icon-m-like?" + hcolor
            anchors.verticalCenter: parent.verticalCenter
        }
        Label {
            id: likeCount
            horizontalAlignment: Text.AlignHCenter
            anchors.left: likeIcon.right
            anchors.right: parent.right
            anchors.verticalCenter: parent.verticalCenter
        }

        onReleased: {
            selected = !selected
            if (selected && dislikeButton.selected) {
                dislikeButton.selected = false;
            }
            root.updateState()
        }
    }

    MouseArea {
        id: dislikeButton
        width: parent.width / 2
        height: dislikeIcon.height
        enabled: root.enabled

        property bool selected: false
        property color activeColor: selected ? "#AAFF0000" : "transparent"

        onSelectedChanged: {
            if (selected) {
                dislikeCount.text = parseInt(dislikeCount.text) + 1
            } else {
                dislikeCount.text = parseInt(dislikeCount.text) - 1
            }
        }

        Rectangle {
            id: dislikeBackground
            anchors.fill: parent
            color: parent.pressed ? Theme.secondaryHighlightColor : parent.activeColor
        }
        Label {
            id: dislikeCount
            horizontalAlignment: Text.AlignHCenter
            anchors.left: parent.left
            anchors.right: dislikeIcon.left
            anchors.verticalCenter: parent.verticalCenter
        }
        Image {
            property color hcolor: parent.pressed ? Theme.highlightColor : Theme.primaryColor
            id: dislikeIcon
            source: "image://theme/icon-m-like?" + hcolor
            anchors.right: parent.right
            anchors.verticalCenter: parent.verticalCenter
            rotation: 180
        }

        onReleased: {
            selected = !selected
            if (selected && likeButton.selected) {
                likeButton.selected = false;
            }
            root.updateState()
        }
    }
}
