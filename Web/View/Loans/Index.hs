{-# LANGUAGE LambdaCase #-}

module Web.View.Loans.Index where
import Web.View.Prelude
import Data.Text (pack)

data IndexView = IndexView { loans :: [Loan]
                           , tools :: [Tool]
                           }

instance View IndexView ViewContext where
    html IndexView { .. } = [hsx|
        <div class="table-responsive">
            <table class="table table-sm;" style="border-top:hidden;">
                <thead class="text-light" style="background-color: #fa6607;">
                    <tr>
                        <th>Verktyg</th>
                        <th>Person</th>
                        <th>Datum Lånat</th>
                        <th>Datum Retur</th>
                        <th></th>
                        <th></th>
                        <th></th>
                    </tr>
                </thead>
                <tbody>
                {
                    let 
                        activeLoans = filter isLoanActive loans
                            |> sortBy (\a b -> compare (get #dateBorrowed a) (get #dateBorrowed b))
                    in
                        renderCollapsableLoans False "Aktiva Lån" tools activeLoans
                }
                {
                    let 
                        inactiveLoans = filter (not . isLoanActive) loans
                            |> sortBy (\b a -> compare (get #dateReturned a) (get #dateReturned b))
                    in
                        renderCollapsableLoans True "Avklarade Lån" tools inactiveLoans
                }
                </tbody>
            </table>
        </div>
    |]

isLoanActive loan = get #dateReturned loan
                    |> \case
                        Just _ -> False
                        Nothing -> True

renderCollapsableLoans collapsed title tools loans = [hsx|
    <tr style="transform: rotate(0);">
        <th>
            <a class="btn btn-link btn-block text-left text-dark stretched-link" data-toggle="collapse" data-target={"#collapse"++(trimSpaces title)} aria-expanded="false" aria-controls={trimSpaces title}>
            {title :: Text}
            </a>
        </th>
        <td></td>
        <td></td>
        <td></td>
        <td></td>
        <td></td>
        <td></td>
    </tr>
    {
        forEach loans (renderLoan collapsed title tools)
    }
|]

collapse :: Bool -> Text
collapse = \case
    True -> pack ""
    False -> pack "show"

renderLoan collapsed title tools loan = [hsx|
    <tr id={"collapse"++(trimSpaces title)} class={"collapse "++(collapse collapsed)} style="transition: none;">
        <td>{
            let
                id = get #toolId loan
            in 
                find (\tool -> get #id tool == id) tools
                    |> \x -> case x of -- TODO: Why can't I use LambdaCase here?
                        Nothing -> "Verktyget finns inte"
                        Just tool -> name tool
            }</td>
        <td>{get #borrower loan}</td>
        <td>{get #dateBorrowed loan}</td>
        <td>{get #dateReturned loan}</td>
        <td><a href={EditLoanAction (get #id loan)} class="text-muted">Ändra</a></td>
        <td><a href={DeleteLoanAction (get #id loan)} class="js-delete text-muted">Ta bort</a></td>
    </tr>
|]
