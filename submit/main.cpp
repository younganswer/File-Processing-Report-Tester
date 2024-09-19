/*
* File Processing Report 2024 - Binary Search Tree skeleton code in C/C++
*
* 본 Skeleton code는 구현에 도움을 주기 위해 작성된 코드입니다.
* ❗️본 Skeleton code는 과제의 요구 조건을 완전히 만족시키지 않습니다.❗️
* ❗️최종 점수 산정은 과제 PDF에 명시된 요구 사항을 기준으로 이루어집니다.❗️
*
*/

#include <iostream>

/*
* 아래는 반드시 사용해야하는 Node 클래스입니다.
* template은 지우고 사용하셔도 무방하지만, 포함해서 사용하시는 것을 추천드립니다.
* ❗️아래 skeleton code는 과제의 명시된 조건을 충족시키지 않습니다.❗️
*/
template <class _Tp>
class Node {
	private: // Member types
		typedef _Tp				key_type;
		typedef std::size_t		size_type;
		typedef Node<key_type>*	__node_pointer_type;
	
	public: // Member variables
		key_type			__key_;
		__node_pointer_type	__left_;
		__node_pointer_type	__right_;
	
	public: // Constructor
		Node(const key_type& key): __key_(key), __left_(nullptr), __right_(nullptr) {}

	/*
	* 아래는 inorder traversal을 대체할 수 있는 operator<< 입니다.
	* 반드시 아래의 함수를 사용해야할 필요는 없습니다.
	*/
	friend std::ostream& operator<<(std::ostream& os, const __node_pointer_type& np) {
		if (np == nullptr) {
			return os;
		}

		os << "< ";
		if (np->__left_ != nullptr) {
			os << np->__left_ << " ";
		}
		os << np->__key_;
		if (np->__right_ != nullptr) {
			os << " " << np->__right_;
		}
		os << " >";
		return os;
	}
};

/*
* 아래는 추천드리는 구현 방법입니다.
* 반드시 아래의 방법을 따라야 하는 것은 아닙니다.
*/

template <class _NodePtr>
unsigned __height(_NodePtr __x) {
	if (__x == nullptr) {
		return 0;
	}
	unsigned __left_height = __height(__x->__left_);
	unsigned __right_height = __height(__x->__right_);
	return 1 + (__left_height < __right_height ? __right_height : __left_height);
}

template <class _NodePtr>
unsigned __size(_NodePtr __x) {
	if (__x == nullptr) {
		return 0;
	}
	return 1 + __size(__x->__left_) + __size(__x->__right_);
}

// 아래는 슬라이드의 minNode와 같은 역할을 하는 함수입니다.
template <class _NodePtr>
_NodePtr __tree_min(_NodePtr __x) {
	while (__x->__left_ != nullptr) {
		__x = __x->__left_;
	}
	return __x;
}

// 아래는 슬라이드의 maxNode와 같은 역할을 하는 함수입니다.
template <class _NodePtr>
_NodePtr __tree_max(_NodePtr __x) {
	while (__x->__right_ != nullptr) {
		__x = __x->__right_;
	}
	return __x;
}

/*
* PDF에 명시되어있는 출력 형식에 유의하세요.
* ❗️잘못된 출력 형식은 0점 처리됩니다.❗️
*/
template <class _NodePtr>
void __inorder(_NodePtr __x) {
	if (__x == nullptr) {
		return;
	}
	std::cout << "< ";
	__inorder(__x->__left_);
	std::cout << " " << __x->__key_ << " ";
	__inorder(__x->__right_);
	std::cout << " >";
}

template <class _NodePtr, class _Tp>
void __insert(_NodePtr& __root, const _Tp& key) {
	if (__root == nullptr) {
		__root = new Node<_Tp>(key);
		return;
	}

	if (key < __root->__key_) {
		__insert(__root->__left_, key);
	} else {
		__insert(__root->__right_, key);
	}
}

template <class _NodePtr>
void __erase_prev(_NodePtr& __root, _NodePtr __z, _NodePtr __z_parent) {
	// if __z has no more than 2 children, then __y will be __z.
	// if __z has two children, then __y will be prev or next by height.
	// __y will have at most one child.

	_NodePtr __y = __z, __y_parent = __z_parent;

	if (__z->__right_ != nullptr) {
		__y_parent = __y;
		__y = __y->__left_;
		while (__y->__right_ != nullptr) {
			__y_parent = __y;
			__y = __y->__right_;
		}
	}
	
	_NodePtr __x = __y->__left_;

	if (__y_parent == nullptr) {
		if (__y == __root) {
			__root = __x;
		}
	} else {
		if (__y_parent != nullptr) {
			if (__y_parent->__left_ == __y) {
				__y_parent->__left_ = __x;
			} else {
				__y_parent->__right_ = __x;
			}
		}
	}

	if (__y != __z) {
		if (__z_parent != nullptr) {
			if (__z_parent->__left_ == __z) {
				__z_parent->__left_ = __y;
			} else {
				__z_parent->__right_ = __y;
			}
		}
		__y->__left_ = __z->__left_;
		__y->__right_ = __z->__right_;
		if (__root == __z) {
			__root = __y;
		}
	}
}

template <class _NodePtr>
void __erase_next(_NodePtr& __root, _NodePtr __z, _NodePtr __z_parent) {
	// if __z has no more than 2 children, then __y will be __z.
	// if __z has two children, then __y will be prev or next by height.
	// __y will have at most one child.

	_NodePtr __y = __z, __y_parent = __z_parent;

	if (__z->__left_ != nullptr && __z->__right_ != nullptr) {
		__y_parent = __y;
		__y = __y->__right_;
		while (__y->__left_ != nullptr) {
			__y_parent = __y;
			__y = __y->__left_;
		}
	}

	_NodePtr __x = __y->__right_;

	if (__y_parent == nullptr) {
		if (__y == __root) {
			__root = __x;
		}
	} else {
		if (__y_parent->__left_ == __y) {
			__y_parent->__left_ = __x;
		} else {
			__y_parent->__right_ = __x;
		}
	}

	if (__y != __z) {
		if (__z_parent != nullptr) {
			if (__z_parent->__left_ == __z) {
				__z_parent->__left_ = __y;
			} else {
				__z_parent->__right_ = __y;
			}
		}
		__y->__left_ = __z->__left_;
		__y->__right_ = __z->__right_;
		if (__root == __z) {
			__root = __y;
		}
	}
}

template <class _NodePtr, class _Tp>
_NodePtr __erase(_NodePtr& __root, const _Tp& key) {
	// __z will be removed from the tree. Client still needs to destruct/deallocate it
	_NodePtr __z = __root, __z_parent = nullptr;

	while (__z != nullptr && __z->__key_ != key) {
		__z_parent = __z;
		if (key < __z->__key_) {
			__z = __z->__left_;
		} else {
			__z = __z->__right_;
		}
	}

	unsigned __left_height = __height(__z->__left_);
	unsigned __right_height = __height(__z->__right_);

	if (__right_height < __left_height) {
		__erase_prev(__root, __z, __z_parent);
	} else if (__left_height < __right_height) {
		__erase_next(__root, __z, __z_parent);
	} else {
		unsigned __left_size = __size(__z->__left_);
		unsigned __right_size = __size(__z->__right_);

		if (__right_size < __left_size) {
			__erase_prev(__root, __z, __z_parent);
		} else {
			__erase_next(__root, __z, __z_parent);
		}
	}

	return __z;
}

template <class _NodePtr>
void __clear(_NodePtr& __x) {
	if (__x == nullptr) {
		return;
	}
	__clear(__x->__left_);
	__clear(__x->__right_);
	delete __x;
	__x = nullptr;
}

/*
* 아래는 반드시 사용해야하는 BST 클래스입니다.
* template은 지우고 구현하셔도 무방하지만, 포함해서 구현하시는 것을 추천드립니다.
*/
template <class _Tp>
class BST {
	public: // Member types
		typedef _Tp			key_type;
		typedef std::size_t	size_type;
	
	private: // Member types
		typedef Node<key_type>*	__node_pointer_type;
	
	private: // Member variables
		__node_pointer_type	__root_;
	
	public: // Constructor
		BST(): __root_(nullptr) {}
	
/*
* 아래의 내용은 반드시 구현해야하는 부분입니다.
* 위의 추천드리는 구현 방법을 사용해서 구현하는 것을 추천합니다.
* 기존 구현 방법을 사용하지 않고 새로 구현하셔도 무방합니다.
*/

	public: // Capacity
		size_type height() const {
			// use __height or write your own code here
			return __height(__root_);
		}

		size_type size() const {
			// use __size or write your own code here
			return __size(__root_);
		}
	
	public: // Lookup
		void inorder() const {
			// use __inorder or write your own code here
			__inorder(__root_);
			std::cout << std::endl;
		}

		/*
		* 아래 함수는 반드시 구현할 필요는 없습니다.
		* 다만, 사용할 가능성이 높은 함수이므로 구현하는 것을 추천드립니다.
		*/
		__node_pointer_type find(const key_type& key) {
			__node_pointer_type ret = __root_;
			while (ret != nullptr && ret->__key_ != key) {
				if (key < ret->__key_) {
					ret = ret->__left_;
				} else {
					ret = ret->__right_;
				}
			}
			return ret;
		}
		
	public: // Modifier
		void insert(const key_type& key) {
			// use __insert or implement your own
			__insert(__root_, key);
		}

		void erase(const key_type& key) {
			// use __erase or implement your own
			__node_pointer_type __r = __erase(__root_, key);

			// Client still needs to destruct/deallocate it
			// Or memory leak will occur
			delete __r; 
		}

		void clear() {
			// use __clear or implement your own
			__clear(__root_);
		}
	
	/*
	* 아래는 inorder traversal을 대체할 수 있는 operator<< 입니다.
	* 반드시 아래의 함수를 사용해야할 필요는 없습니다.
	*/
	friend std::ostream& operator<<(std::ostream& os, const BST& tree) {
		os << tree.__root_;
		return os;
	}
};

/*
* 아래는 추천드리는 main 함수의 예시입니다.
* 반드시 아래의 main 함수를 사용해야할 필요는 없습니다.
* ❗️새로 구현하실 경우, 출력 형식에 주의하세요.❗️
*/
int main(int argc, char **argv) {
	BST<int>	tree;
	char		command;
	int			key;

	while (std::cin >> command >> key) {
		switch ((int)command) {
			case (int)'i':
				if (tree.find(key) != nullptr) {
					std::cerr << "i " << key << ": The key already exists" << std::endl;
					continue;
				}
				tree.insert(key);
				break;
			case (int)'d':
				if (tree.find(key) == nullptr) {
					std::cerr << "d " << key << ": The key does not exist" << std::endl;
					continue;
				}
				tree.erase(key);
				break;
			default:
				std::cerr << "Invalid command: " << command << std::endl;
				return (1);
				break;
		}
		std::cout << tree << std::endl;
	}

	tree.clear();
	
	return (0);
}