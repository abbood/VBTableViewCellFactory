This library uses the Factory pattern to dynamically create UITableViewCells.. examlpe usage:

```

- (void)setupTableView
{

    NSDictionary *dependencies = @{(id<NSCopying>)[VBSongFavouritingBehavior class]: [VBSongCellBehaviour class]};
    _detailDeleteSongCellReuseId = [VBTableViewCellFactory reuseIdentifierWithRootType:VBRootCellTypeSwipable
                                                                            behaviours:@[[VBSongCellBehaviour class],[VBRightDetailsButtonsCellBehaviour class],[VBRightDeleteButtonCellBehaviour class], [VBUnavailableSongCellBehaviour class], [VBSongFavouritingBehavior class]]
														                    proxyClass:[VBSelectableCellProxy class]
                                                                          dependencies:dependencies];

    [self.tableView registerClass:[VBTableViewCellFactory class]
           forCellReuseIdentifier:_detailDeleteSongCellReuseId];


    _detailSongCellReuseId = [VBTableViewCellFactory reuseIdentifierWithRootType:VBRootCellTypeSwipable
                                                                      behaviours:@[[VBSongCellBehaviour class],[VBRightDetailsButtonsCellBehaviour class],[VBUnavailableSongCellBehaviour class], [VBSongFavouritingBehavior class]]
															          proxyClass:[VBSelectableCellProxy class]
                                                                    dependencies:dependencies];


    [self.tableView registerClass:[VBTableViewCellFactory class]
           forCellReuseIdentifier:_detailSongCellReuseId];
    
    [self.tableView registerClass:[VBNoTracksAddedViewCell class]
           forCellReuseIdentifier:VBNoTracksAddedViewCellIdentifier];
    
    [self.tableView registerClass:[VBDraggedOverTableViewCell class]
           forCellReuseIdentifier:VBDraggedOverTableViewCellIdentifier];

    DDLogVerbose(@"Clearing list of unplayable songs");

    [self.tableView setSeparatorColor:[UIColor VBColor8]];
}

```
