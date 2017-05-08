class bkSearchViewController: BaseViewController, UserSelecting, StreamSelecting, ProfileDelegate, UserStatusDelegate
{
    var dataSource:SearchDataSource?
    
    @IBOutlet var searchBar:UISearchBar!
    @IBOutlet var tableView:UITableView!
    
    func searchBar(searchBar:UISearchBar, textDidChange searchText:String)
    {
        if searchText.characters.count>0&&(dataSource!.mode=="streams"||dataSource!.mode=="people")
        {
            dataSource!.search(searchText)
        }
    }
    
    func configureView()
    {
        tableView.addInfiniteScrollingWithActionHandler
            {()->Void in
                self.dataSource!.fetchMore()
        }
        
        dataSource=SearchDataSource(tableView:tableView)
        dataSource!.userSelectedDelegate=self
        dataSource!.streamSelectedDelegate=self
    }
    
    override func viewDidLoad()
    {
        configureView()
        
        dataSource!.reload()
    }
    
    override func viewWillAppear(animated:Bool)
    {
        self.navigationController?.navigationBarHidden=true
    }
    
    func reload()
    {
        dataSource!.reload()
    }
    
    func close()
    {
        
    }
    
    func followStatusDidChange(status:Bool, user:User)
    {
        dataSource!.updateUser(user, isFollowed:status, isBlocked:user.isBlocked)
    }
    
    func blockStatusDidChange(status:Bool, user:User)
    {
        dataSource!.updateUser(user, isFollowed:user.isFollowed, isBlocked:status)
    }
    
    func userDidSelected(user:User)
    {
        searchBar.resignFirstResponder()
    }
    
    func streamDidSelected(stream:Stream)
    {
        let storyboard=UIStoryboard(name:"Main", bundle:nil)
        let modalVC=storyboard.instantiateViewControllerWithIdentifier("ModalViewController") as! ModalViewController
        
        modalVC.stream=stream
        
        presentViewController(modalVC, animated:true, completion:nil)
    }
    
    func openPopUpForSelectedStream(stream:Stream)
    {
        
    }
}
