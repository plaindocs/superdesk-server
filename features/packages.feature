Feature: Packages

    @auth
    Scenario: Empty packages list
        Given empty "packages"
        When we get "/packages"
        Then we get list with 0 items

    @auth
    Scenario: Create new package without groups
        Given empty "packages"
        When we post to "/packages"
        """
        {
        "guid": "tag:example.com,0000:newsml_BRE9A605",
        "groups": []
        }
        """
        Then we get error 400
        """
        {
            "_error": {"code": 400, "message": "Insertion failure: 1 document(s) contain(s) error(s)"},
            "_issues": {"groups": {"minlength": 1}},
            "_status": "ERR"
        }
        """
    
    @auth
    Scenario: Create new package with text content
        Given empty "packages"
        When we post to "archive"
	    """
        [{"headline": "test"}]
	    """
        When we post to "/packages" with success
        """
        {
            "groups": [
                {
                    "group": {
                        "associations": [
                            {
                                "headline": "test package with text",
                                "itemRef": "/archive/#ARCHIVE_ID#",
                                "slugline": "awesome article"
                            }
                        ],
                        "role": "main"
                    }
                }
            ],
            "guid": "tag:example.com,0000:newsml_BRE9A605"
        }
        """
        And we get "/packages"
        Then we get list with 1 items
            """
            {
                "_items": [
                    {
                        "groups": [
                            {
                                "group": {
                                    "associations": [
                                        {
                                            "headline": "test package with text",
                                            "itemRef": "/archive/#ARCHIVE_ID#",
                                            "slugline": "awesome article"
                                        }
                                    ],
                                    "role": "main"
                                }
                            }
                        ],
                        "guid": "tag:example.com,0000:newsml_BRE9A605"
                    }
                ]
            }
            """

    @auth
    Scenario: Create new package with image content
        Given empty "packages"
        When we upload a file "bike.jpg" to "archive_media"
        When we post to "/packages" with success
        """
        {
            "groups": [
                {
                    "group": {
                        "associations": [
                            {
                                "headline": "test package with pic",
                                "itemRef": "/archive/#ARCHIVE_MEDIA_ID#",
                                "slugline": "awesome picture"
                            }
                        ],
                        "role": "main"
                    }
                }
            ]
        }
        """
        And we get "/packages"
        Then we get list with 1 items
            """
            {
                "_items": [
                    {
                        "groups": [
                            {
                                "group": {
                                    "associations": [
                                        {
                                            "headline": "test package with pic",
                                            "itemRef": "/archive/#ARCHIVE_MEDIA_ID#",
                                            "slugline": "awesome picture"
                                        }
                                    ],
                                    "role": "main"
                                }
                            }
                        ]
                    }
                ]
            }
            """

    @auth
    Scenario: Create package with image and text
        Given empty "packages"
        When we upload a file "bike.jpg" to "archive_media"
        When we post to "archive"
	    """
        [{"headline": "test"}]
	    """
        When we post to "/packages" with success
        """
        {
            "groups": [
                {
                    "group": {
                        "associations": [
                            {
                                "headline": "test package with pic",
                                "itemRef": "/archive/#ARCHIVE_MEDIA_ID#",
                                "slugline": "awesome picture"
                            },
                            {
                                "headline": "test package with text",
                                "itemRef": "/archive/#ARCHIVE_ID#",
                                "slugline": "awesome article"
                            }
                        ],
                        "role": "main"
                    }
                }
            ]
        }
        """
        And we get "/packages"
        Then we get list with 1 items
            """
            {
                "_items": [
                    {
                        "groups": [
                            {
                                "group": {
                                    "associations": [
                                        {
                                            "headline": "test package with pic",
                                            "itemRef": "/archive/#ARCHIVE_MEDIA_ID#",
                                            "slugline": "awesome picture"
                                        },
                                        {
                                            "headline": "test package with text",
                                            "itemRef": "/archive/#ARCHIVE_ID#",
                                            "slugline": "awesome article"
                                        }
                                    ],
                                    "role": "main"
                                }
                            }
                        ]
                    }
                ]
            }
            """

    @auth
    Scenario: Fail on creating new package with duplicated content
        Given empty "packages"
        When we post to "/packages"
        """
        {
            "groups": [
                {
                    "group": {
                        "associations": [
                            {
                                "headline": "test package with pic",
                                "itemRef": "/archive/#ARCHIVE_ID#",
                                "slugline": "awesome picture"
                            },
                            {
                                "headline": "test package with text",
                                "itemRef": "/archive/#ARCHIVE_ID#",
                                "slugline": "awesome article"
                            }
                        ],
                        "role": "main"
                    }
                }
            ]
        }
        """
        Then we get error 400
        """
        {
            "_message": "Content associated multiple times",
            "_status": "ERR"
        }
        """

    @auth
    Scenario: Fail on creating package with circular reference
        When we post to "archive"
	    """
        [{"headline": "test"}]
	    """
        When we post to "/packages" with success
        """
        {
            "guid": "tag:example.com,0000:newsml_BRE9A605",
            "groups": [
                {
                    "group": {
                        "associations": [
                            {
                                "headline": "test package with text",
                                "itemRef": "/archive/#ARCHIVE_ID#",
                                "slugline": "awesome article"
                            }
                        ],
                        "role": "main"
                    }
                }
            ]
        }
        """
        When we post to "/packages" with success
        """
        {
            "groups": [
                {
                    "group": {
                        "associations": [
                            {
                                "headline": "test package with text",
                                "itemRef": "/archive/#ARCHIVE_ID#",
                                "slugline": "awesome article"
                            },
                            {
                                "headline": "test package with text",
                                "itemRef": "/packages/tag:example.com,0000:newsml_BRE9A605",
                                "slugline": "awesome circular article"
                            }
                        ],
                        "role": "main story"
                    }
                }
            ]
        }
        """
        And we patch "/packages/tag:example.com,0000:newsml_BRE9A605"
        """
        {
            "groups": [
                {
                    "group": {
                        "associations": [
                            {
                                "headline": "test package with text",
                                "itemRef": "/archive/#ARCHIVE_ID#",
                                "slugline": "awesome article"
                            },
                            {
                                "headline": "test package with text",
                                "itemRef": "/packages/#PACKAGES_ID#",
                                "slugline": "awesome circular article"
                            }
                        ]
                    }
                }
            ],
            "guid": "tag:example.com,0000:newsml_BRE9A605"
        }
        """
        Then we get error 400
        """
        {
            "_issues": {
                "validator exception": "Trying to create a circular reference to: #PACKAGES_ID#"
            },
            "_status": "ERR"
        }
        """
 
    @auth
    Scenario: Retrieve created package
        Given empty "packages"
        When we post to "archive"
	    """
        [{"headline": "test"}]
	    """
        When we post to "/packages" with success
        """
        {
            "groups": [
                {
                    "group": {
                        "associations": [
                            {
                                "headline": "test package with text",
                                "itemRef": "/archive/#ARCHIVE_ID#",
                                "slugline": "awesome article"
                            }
                        ],
                        "role": "main"
                    }
                }
            ],
            "guid": "tag:example.com,0000:newsml_BRE9A605"
        }
        """
        Then we get new resource
        """
        {
            "groups": [
                {
                    "group": {
                        "associations": [
                            {
                                "headline": "test package with text",
                                "itemRef": "/archive/#ARCHIVE_ID#",
                                "slugline": "awesome article"
                            }
                        ],
                        "role": "main"
                    }
                }
            ],
            "guid": "tag:example.com,0000:newsml_BRE9A605",
            "type": "composite"
        }
        """
        And we get latest
        When we get "/archive"
        Then we get list with 2 items
        """
        {
            "_items": [
                {
                    "guid": "#ARCHIVE_ID#",
                    "headline": "test",
                    "linked_in_packages": [{"package": "#PACKAGES_ID#"}],
                    "type": "text"
                },
                {
                    "groups": [
                        {
                            "group": {
                                "associations": [
                                    {
                                        "headline": "test package with text",
                                        "itemRef": "/archive/#ARCHIVE_ID#",
                                        "slugline": "awesome article"
                                    }
                                ],
                                "role": "main"
                            }
                        }
                    ],
                    "guid": "tag:example.com,0000:newsml_BRE9A605",
                    "type": "composite"
                }
            ]
        }
        """
        
    @auth
    Scenario: Patch created package
        Given empty "packages"
        When we post to "archive"
	    """
        [{"headline": "test"}]
	    """
        When we upload a file "bike.jpg" to "archive_media"
        When we post to "/packages" with success
        """
        {
            "groups": [
                {
                    "group": {
                        "associations": [
                            {
                                "headline": "test package with text",
                                "itemRef": "/archive/#ARCHIVE_ID#",
                                "slugline": "awesome article"
                            }
                        ],
                        "role": "main"
                    }
                }
            ]
        }
        """
        And we patch latest
        """
        {
            "groups": [
                {
                    "group": {
                        "associations": [
                            {
                                "headline": "test package with pic",
                                "itemRef": "/archive/#ARCHIVE_MEDIA_ID#",
                                "slugline": "awesome picture"
                            },
                            {
                                "headline": "test package with text",
                                "itemRef": "/archive/#ARCHIVE_ID#",
                                "slugline": "awesome article"
                            }
                        ],
                        "role": "main"
                    }
                }
            ]
        }
        """
        Then we get existing resource
        """
        {
            "groups": [
                {
                    "group": {
                        "associations": [
                            {
                                "headline": "test package with pic",
                                "itemRef": "/archive/#ARCHIVE_MEDIA_ID#",
                                "slugline": "awesome picture"
                            },
                            {
                                "headline": "test package with text",
                                "itemRef": "/archive/#ARCHIVE_ID#",
                                "slugline": "awesome article"
                            }
                        ],
                        "role": "main"
                    }
                }
            ],
            "type": "composite"
        }
        """

    @auth
    Scenario: Delete created package
        Given empty "packages"
        When we post to "archive"
	    """
        [{"headline": "test"}]
	    """
        When we post to "/packages" with success
        """
        {
            "groups": [
                {
                    "group": {
                        "associations": [
                            {
                                "headline": "test package with text",
                                "itemRef": "/archive/#ARCHIVE_ID#",
                                "slugline": "awesome article"
                            }
                        ],
                        "role": "main"
                    }
                }
            ]
        }
        """
        When we delete latest
        Then we get response code 405
        When we get "/archive"
        Then we get list with 2 items
        """
        {"_items": [{"guid": "#ARCHIVE_ID#", "headline": "test", "linked_in_packages": [], "type": "text"}]}
        """
