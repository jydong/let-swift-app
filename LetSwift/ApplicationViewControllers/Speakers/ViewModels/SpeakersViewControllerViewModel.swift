//
//  SpeakersViewControllerViewModel.swift
//  LetSwift
//
//  Created by Kinga Wilczek on 14.06.2017.
//  Copyright © 2017 Droids On Roids. All rights reserved.
//
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//       http://www.apache.org/licenses/LICENSE-2.0
//
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.
//

import Foundation
import Alamofire

final class SpeakersViewControllerViewModel {

    private enum Constants {
        static let speakersPerPage = 10
        static let firstPage = 1
        static let cancelCode = -999
    }

    enum ErrorReason {
        case requestFail
        case speakerNotFound
    }

    private let disposeBag = DisposeBag()
    private var currentPage = Constants.firstPage
    private var totalPage = -1
    private var pendingRequest: Request?
    private var searchQuery = ""

    var speakerLoadDataRequestObservable = Observable<Void>()
    var tableViewStateObservable: Observable<AppContentState>
    var checkIfLastSpeakerObservable = Observable<Int>(-1)
    var tryToLoadMoreDataObservable = Observable<Void>()
    var noMoreSpeakersToLoadObservable = Observable<Void>()
    var errorOnLoadingMoreSpeakersObservable = Observable<Void>()
    var refreshDataObservable = Observable<Void>()
    var speakerCellDidTapWithIndexObservable = Observable<Int>(-1)
    var latestSpeakerCellDidTapWithIndexObservable = Observable<Int>(-1)
    var searchQueryObservable = Observable<String>("")
    var searchBarShouldResignFirstResponderObservable = Observable<Void>()
    var errorViewStateObservable = Observable<ErrorReason>(.requestFail)

    weak var delegate: SpeakerLectureFlowDelegate?
    var speakers = [Speaker]().bindable
    var latestSpeakers = [Speaker]().bindable

    init(delegate: SpeakerLectureFlowDelegate?) {
        self.delegate = delegate
        tableViewStateObservable = Observable<AppContentState>(.loading)

        setup()
    }

    private func setup() {
        speakerLoadDataRequestObservable.subscribeNext { [weak self] in
            guard self?.pendingRequest == nil else { return }

            self?.tableViewStateObservable.next(.loading)
            self?.loadInitialData()
        }
        .add(to: disposeBag)

        checkIfLastSpeakerObservable.subscribeNext { [weak self] index in
            guard let weakSelf = self, weakSelf.speakers.values.count - 1 == index else { return }

            weakSelf.loadMoreData()
        }
        .add(to: disposeBag)

        tryToLoadMoreDataObservable.subscribeNext { [weak self] in
            self?.loadMoreData()
        }
        .add(to: disposeBag)

        refreshDataObservable.subscribeNext { [weak self] in
            guard self?.pendingRequest == nil else { return }

            self?.loadInitialData()
        }
        .add(to: disposeBag)

        speakerCellDidTapWithIndexObservable.subscribeNext { [weak self] index in
            guard let speakerId = self?.speakers.values[index].id else { return }
            self?.delegate?.presentSpeakerDetailsScreen(with: speakerId)
        }
        .add(to: disposeBag)

        latestSpeakerCellDidTapWithIndexObservable.subscribeNext { [weak self] index in
            guard let speakerId = self?.latestSpeakers.values[index].id else { return }
            self?.delegate?.presentSpeakerDetailsScreen(with: speakerId)
        }
        .add(to: disposeBag)

        searchQueryObservable.subscribeNext { [weak self] query in
            self?.pendingRequest?.cancel()
            self?.pendingRequest = nil
            self?.searchQuery = query
        }
        .add(to: disposeBag)
    }

    private func loadInitialData() {
        pendingRequest = NetworkProvider.shared.speakersList(with: Constants.firstPage, perPage: Constants.speakersPerPage, query: searchQuery) { [weak self] response in
            guard let weakSelf = self else { return }

            switch response {
            case let .success(responeObject):
                weakSelf.speakers.values = []
                weakSelf.speakers.append(responeObject.elements)
                weakSelf.totalPage = responeObject.page.pageCount
                weakSelf.currentPage = Constants.firstPage

                if weakSelf.searchQuery.isEmpty || weakSelf.latestSpeakers.values.isEmpty {
                    weakSelf.loadLatestSpeakers()
                } else {
                    weakSelf.tableViewStateObservable.next(weakSelf.checkIfNoResultsFound())
                    weakSelf.pendingRequest = nil
                    weakSelf.refreshDataObservable.complete()
                }
            case .error(let error):
                guard (error as NSError).code != Constants.cancelCode else { return }

                weakSelf.errorViewStateObservable.next(.requestFail)
                weakSelf.tableViewStateObservable.next(.error)
                weakSelf.refreshDataObservable.complete()
                weakSelf.pendingRequest = nil
            }
        }
    }

    private func loadLatestSpeakers() {
        NetworkProvider.shared.latestSpeakers { [weak self] response in
            guard let weakSelf = self else { return }

            switch response {
            case let .success(latestSpeakers):
                weakSelf.latestSpeakers.values = []
                weakSelf.latestSpeakers.append(latestSpeakers)
                weakSelf.tableViewStateObservable.next(weakSelf.checkIfNoResultsFound())
            case .error:
                weakSelf.errorViewStateObservable.next(.requestFail)
                weakSelf.tableViewStateObservable.next(.error)
            }
            weakSelf.refreshDataObservable.complete()
            weakSelf.pendingRequest = nil
        }
    }

    private func loadMoreData() {
        guard pendingRequest == nil else { return }

        guard currentPage < totalPage || totalPage == -1 else {
            noMoreSpeakersToLoadObservable.next()
            return
        }

        pendingRequest = NetworkProvider.shared.speakersList(with: currentPage + 1, perPage: Constants.speakersPerPage, query: searchQuery) { [weak self] response in
            switch response {
            case let .success(responeObject):
                self?.currentPage += 1
                self?.speakers.append(responeObject.elements)
                self?.totalPage = responeObject.page.pageCount
            default:
                self?.errorOnLoadingMoreSpeakersObservable.next()
            }

            self?.pendingRequest = nil
        }
    }

    private func checkIfNoResultsFound() -> AppContentState {
        if speakers.values.isEmpty && !searchQuery.isEmpty {
            errorViewStateObservable.next(.speakerNotFound)
            return .error
        } else {
            return .content
        }
    }
}
